# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  discarded_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  family_name            :string
#  given_name             :string
#  last_request_at        :datetime
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  nickname               :string
#  profile                :jsonb
#  providers              :string           default([]), is an Array
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  timeout_in             :integer          default(1800)
#  uids                   :jsonb
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_discarded_at          (discarded_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist
  include Discard::Model

  has_paper_trail

  class << self
    # Docs on Devise passwordless customization: https://github.com/abevoelker/devise-passwordless#customization
    def passwordless_login_within
      15.minutes
    end

    def from_omniauth(access_token = nil)
      access_token ||= Current.auth_provider
      result = UpsertUserFromOmniauthWorkflow.call(access_token:)
      # Returns either the user instance with errors or the persisted user record
      # TODO: Add a spec that asserts that when the transaction fails, a user instance
      #   with errors is returned
      result.user
    end
  end

  rolify

  # Alumnus->Product: Has been a customer or subscriber to a product or service in the past and is currently
  #   NOT subscribed through any of the accounts they have access to.
  # Customer->Product: Is currently subscribed or in active service with a product or vendor.
  # Subscriber->Business: Opted-in for updates from a vendor or product but is not a customer or subscriber.
  # Subscriber->Product: Opted-in for updates from a product or service but is not a customer or subscriber.
  # Manager->Account: Has access to the admin panel and can manage users, products or other resources on an account.
  # Manager: Has access to the admin panel and can manage users, products or other resources on any account.
  # Admin->Account: Has access to the admin panel and can manage users, products or other resources on an account.
  # Admin: Has access to the admin panel and can manage users, products or other resources on any account.
  # User: Has access to the user dashboard and can manage their own account, invoices and subscriptions.
  # :role => :privilege_level
  SUPPORTED_ROLES = {
    # role => [privilege_level, display_name]
    admin: [100, 'Admin'],
    manager: [90, 'Manager'],
    subscriber: [80, 'Subscriber'],
    alumnus: [70, 'Alum'],
    customer: [60, 'Customer'],
    user: [10, 'Default'],
  }.freeze

  SELF_SERVICE_ROLES = %i[admin manager subscriber user].freeze

  # Source code for confirmable: https://github.com/heartcombo/devise/blob/main/lib/devise/models/confirmable.rb
  # Guide on adding confirmable: https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :recoverable,
         :confirmable, :timeoutable, :lockable, :trackable

  # # Guide on model config: https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#model-configuration
  devise :jwt_authenticatable, jwt_revocation_strategy: self

  devise :omniauthable, omniauth_providers: %i[google]

  alias_attribute :first_name, :given_name
  alias_attribute :last_name, :family_name

  validates :email, presence: true, uniqueness: true, email: true

  # Doc on name_of_person gem: https://github.com/basecamp/name_of_person
  has_person_name

  has_many :identity_provider_profiles, dependent: :destroy

  before_validation :cleanup_providers, if: :providers_changed?

  def admin?
    has_role?(:admin)
  end

  def flipper_id
    id
  end

  def assign_default_role
    add_role(:user)
  end

  def maybe_assign_default_role
    assign_default_role unless has_role?(:user)
  end

  # def jwt_payload
  #   super.merge(foo: 'bar')
  # end
  #
  # # IMPORTANT: This method is used by the AllowList revocation strategy
  # def on_jwt_dispatch(token, payload)
  #   super
  #   do_something(token, payload)
  # end

  # https://github.com/heartcombo/devise?tab=readme-ov-file#active-job-integration
  # def send_devise_notification(notification, *args)
  #   devise_mailer.send(notification, self, *args).deliver_later
  # end
  #
  # TODO: Test attempting to activate several accounts and ensure only the ones
  #   that are not already activated are activated
  # def after_confirmation
  #   accounts.each(&:activate!)
  # end
  #
  def after_magic_link_authentication
    maybe_assign_default_role
    # NOTE: Consider the successful completion of a magic link authentication
    #  as a confirmation of the user's email address
    confirm unless confirmed?
  end

  private

  def cleanup_providers
    return if providers.blank?

    self.providers = providers.uniq
  end
end
