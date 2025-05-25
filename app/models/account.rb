# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id            :uuid             not null, primary key
#  discarded_at  :datetime
#  display_name  :string
#  email         :string
#  metadata      :jsonb
#  phone         :jsonb
#  readme        :text
#  slug          :string
#  status        :integer
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  parent_id     :uuid
#  remote_crm_id :string
#  tax_id        :string
#
# Indexes
#
#  by_account_email_if_set         (email) UNIQUE NULLS NOT DISTINCT WHERE (email IS NOT NULL)
#  index_accounts_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => accounts.id)
#
class Account < ApplicationRecord
  # TODO: This change was suggested before the application was ever deployed.
  #   We should be able to delete this line - the database would have been
  #   re-initialized several times since then prior to the first deployment.
  self.ignored_columns += ['parent_account_id']

  # Class methods
  def self.ransackable_attributes(_auth_object = nil)
    %w[display_name email slug tax_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[invoices members rich_text_readme roles]
  end
  # End of class methods

  resourcify
  rolify

  include AASM
  include Discard::Model
  include Searchable
  include Actionable
  include Renderable

  # There are security implications to consider when using deterministic encryption.
  # See https://guides.rubyonrails.org/active_record_encryption.html#deterministic-and-non-deterministic-encryption
  encrypts :tax_id, deterministic: true

  has_rich_text :readme

  supported_actions :show, :edit, :destroy

  attribute :type, :string, default: 'Account'
  attribute :slug, :string, default: -> { SecureRandom.alphanumeric(4).downcase }
  attribute :metadata, :jsonb, default: { contacts: [] }

  validates :display_name, presence: true
  validates :email, email: true, allow_nil: true, uniqueness: { case_sensitive: false }
  validates :type, presence: true, inclusion: { in: %w[Account Business Individual Government Nonprofit Vendor] }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :tax_id, uniqueness: { case_sensitive: false }, allow_blank: true, allow_nil: true
  # Intended to store the ZohoCRM SOID
  validates :remote_crm_id, uniqueness: { case_sensitive: false }, allow_blank: true, allow_nil: true

  # See https://guides.rubyonrails.org/association_basics.html#self-joins
  belongs_to :parent, class_name: 'Account', optional: true
  has_many :dupes, class_name: 'Account', foreign_key: 'parent_id'
  has_many :invoices, as: :invoiceable, dependent: :nullify
  # TODO: This generates the following console error:
  #   `warning: already initialized constant Account::HABTM_Roles`
  #   However, without this line, the behavior of assigning
  #   roles to accounts on invoices breaks.
  # has_and_belongs_to_many :roles, dependent: :destroy
  has_and_belongs_to_many :members, class_name: 'User', join_table: 'accounts_users'

  # @deprecated use the direct "members" relationship instead. I guess we're
  #   going to learn interesting things about aliasing associations in Rails 😅
  alias users members

  before_validation :format_tax_id, if: :tax_id_changed?
  after_commit :push_to_crm,
               on: %i[create update],
               if: -> { Flipper.enabled?(:feat__push_updates_to_crm) && crm_relevant_changes? }

  has_rich_text :readme

  def assign_default_role
    add_role(:owner, Current.user) unless Current.user.nil? || Current.user.admin?
  end

  def primary_users_confirmed?
    # TODO: Check that all primary users have confirmed their email addresses
    true
  end

  enum :status, {
    demo: 1,
    draft: 2,
    guest: 5,
    active: 10,
    paid: 20,
    payment_due: 25,
    overdue: 30,
    suspended: 35,
    deactivated: 40,
  }, scopes: true

  aasm column: :status, enum: true, logger: Rails.logger do
    state :draft, initial: true
    state :demo
    state :guest
    state :active
    state :paid
    state :payment_due
    state :overdue
    state :suspended
    state :deactivated

    event :invite do
      transitions from: %i[demo], to: :guest
    end

    # TODO: Figure out how to designate primary users
    # TODO: Ensure that all primary users are guided to confirm their email addresses
    #   as soon as their accounts are created so service can be activated
    event :activate do
      transitions from: %i[demo guest], to: :active, guard: :primary_users_confirmed?
    end

    event :enroll do
      transitions from: %i[active payment_due overdue], to: :paid
    end

    event :invoice do
      transitions from: %i[active paid], to: :payment_due
    end

    # NOTE: Account suspension happens after the user has failed to pay an invoice or subscription
    #   and the overdue period has passed
    event :suspend do
      transitions from: %i[active payment_due overdue], to: :suspended
    end

    # NOTE: Reactivation can happen after the user has paid an overdue invoice or subscription
    event :reactivate do
      transitions from: %i[suspended overdue deactivated], to: :active
    end

    event :deactivate do
      transitions from: %i[active payment_due overdue suspended], to: :deactivated
    end
  end

  def add_member(user)
    members << user
  end

  # TODO: Add specs for this method
  def crm_url
    return nil if remote_crm_id.blank?

    crm_resource_url("tab/Accounts/#{remote_crm_id}")
  end

  def crm_relevant_changes?
    email_changed? || display_name_changed? || readme_body_changed? || tax_id_changed? || phone_changed?
  end

  def readme_body_changed?
    return false if readme.blank?

    readme.body_changed?
  end

  private

  def format_tax_id
    self.tax_id = tax_id.upcase if tax_id.present?
  end

  def push_to_crm
    return unless Flipper.enabled?(:feat__push_updates_to_crm)

    Zoho::UpsertAccountJob.set(wait: 5.seconds).perform_later(id)
  end
end
