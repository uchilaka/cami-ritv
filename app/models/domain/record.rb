# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_records
#
#  id               :uuid             not null, primary key
#  name             :string
#  priority         :integer
#  status           :string           default("active")
#  ttl              :integer          default(1800)
#  type             :string           not null
#  value            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  domain_name_id   :uuid             not null
#  vendor_record_id :string
#
# Indexes
#
#  index_domain_records_on_domain_and_name_and_type  (domain_name_id,name,type)
#  index_domain_records_on_domain_name_id            (domain_name_id)
#  index_domain_records_on_vendor_record_id          (vendor_record_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_name_id => domain_names.id)
#
module Domain
  class Record < ApplicationRecord
    include AASM

    self.inheritance_column = nil

    TYPES = %w[A AAAA CNAME MX TXT SRV].freeze

    belongs_to :domain_name, class_name: 'Domain::Name', foreign_key: 'domain_name_id'

    validates :status, inclusion: { in: STATUSES }
    validates :type, presence: true, inclusion: { in: TYPES }
    validates :value, presence: true

    aasm column: :status, logger: Rails.logger do
      state :active, initial: true
      state :error
      state :inactive
      state :pending
      state :suspended
      state :retired

      event :alert do
        transitions from: :active, to: :error
      end

      # When a domain (DNS) record is created before an account is created,
      # it will be in the pending state until the account is created
      # and the related domain name is associated with the account.
      # Once the domain name is associated with the account, then all
      # related domain records can be activated.
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
