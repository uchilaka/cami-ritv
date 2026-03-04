# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_records
#
#  id               :uuid             not null, primary key
#  name             :string
#  priority         :integer
#  status           :string           default("pending")
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

    # This model does not use STI, so we need to disable the inheritance column
    # to prevent Rails from trying to use the 'type' column for STI.
    self.inheritance_column = nil

    TYPES = %w[A AAAA CNAME MX TXT NS].freeze

    belongs_to :domain_name, class_name: 'Domain::Name', foreign_key: 'domain_name_id'

    validates :domain_name, presence: true
    validates :status, inclusion: { in: STATUSES }
    validates :type, presence: true, inclusion: { in: TYPES }
    validates :name,
              uniqueness: { scope: %i[domain_name_id type], case_sensitive: false },
              if: :a_record?
    validates :value, presence: true
    validates :value, ip_address: true, if: :a_record?
    validates :value,
              uniqueness: { scope: %i[domain_name_id name type], case_sensitive: false },
              if: :ns_record?
    validates :value,
              uniqueness: { scope: %i[domain_name_id name type], case_sensitive: false },
              if: :cname_record?
    validates :value, unique_dns_a_record: true, on: :create, if: :a_record?
    validates :value, unique_dns_cname_record: true, on: :create, if: :cname_record?
    validates :value, unique_dns_ns_record: true, on: :create, if: :ns_record?

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

    # All records of a given type for a specific domain_name
    scope :by_type_and_domain, lambda { |type, hostname|
      joins(:domain_name)
        .where(domain_records: { type: }, domain_names: { hostname: })
    }

    # All records of a given type for a specific subdomain.domain_name
    scope :by_type_domain_and_name, lambda { |type, hostname, name|
      joins(:domain_name)
        .where(domain_records: { type:, name: }, domain_names: { hostname: })
    }

    # @deprecated This scope should not be used - dependent implementations should
    #   instead implement a relevant active query on any attributes as needed. This
    #   scope should be replaced with a more useful generic scope for managing sets
    #   of DNS records like :by_type_domain_and_name.
    scope :by_type_domain_and_value, lambda { |type, hostname, value|
      joins(:domain_name)
        .where(domain_records: { type:, value: }, domain_names: { hostname: })
    }

    def cname_record?
      type == 'CNAME'
    end

    def a_record?
      type == 'A'
    end

    def ns_record?
      type == 'NS'
    end
  end
end
