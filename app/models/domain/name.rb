# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_names
#
#  id         :uuid             not null, primary key
#  hostname   :string           not null
#  status     :string           default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vendor_id  :uuid
#
# Indexes
#
#  index_domain_names_on_vendor_id  (vendor_id)
#  index_domains_on_name            (hostname) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (vendor_id => accounts.id)
#
module Domain
  class Name < ApplicationRecord
    include AASM

    def self.find_or_initialize_as_active_by_hostname(hostname)
      record = find_or_initialize_by(hostname:)
      return record unless record.new_record?

      record.status = 'active'
      record
    end

    belongs_to :vendor, class_name: 'Account', foreign_key: 'vendor_id', optional: true
    has_many :records, class_name: 'Domain::Record', foreign_key: 'domain_name_id', dependent: :destroy

    validates :hostname, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUSES }

    aasm column: :status, logger: Rails.logger do
      state :active
      state :error
      state :inactive
      state :pending, initial: true
      state :suspended
      state :retired

      event :alert do
        transitions from: :active, to: :error
      end

      # When a domain name is created before an account is created,
      # it will be in the pending state until the account is created
      # and the domain name is associated with the account. Once the
      # domain name is associated with the account, it can be activated.
      event :activate do
        transitions from: :pending, to: :active
      end

      event :deactivate do
        transitions from: :active, to: :inactive
      end

      event :reactivate do
        transitions from: %i[suspended error], to: :active
      end

      event :suspend do
        transitions from: %i[active pending], to: :suspended
      end

      event :retire do
        transitions from: %i[active pending suspended error], to: :retired
      end
    end
  end
end
