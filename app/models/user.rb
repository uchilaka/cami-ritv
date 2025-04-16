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
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  timeout_in             :integer          default(1800)
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
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

  # Source code for confirmable: https://github.com/heartcombo/devise/blob/main/lib/devise/models/confirmable.rb
  # Guide on adding confirmable: https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :recoverable,
         :confirmable, :timeoutable, :lockable, :trackable
  # Guide on model config: https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#model-configuration
  devise :omniauthable, omniauth_providers: %i[google]

  alias_attribute :first_name, :given_name
  alias_attribute :last_name, :family_name

  validates :email, presence: true, uniqueness: true, email: true

  # Doc on name_of_person gem: https://github.com/basecamp/name_of_person
  has_person_name

  has_many :identity_provider_profiles, dependent: :destroy

  before_validation :cleanup_providers, if: :providers_changed?

  private

  def cleanup_providers
    return if providers.blank?

    self.providers = providers.uniq
  end
end
