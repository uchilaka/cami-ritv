# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_names
#
#  id         :uuid             not null, primary key
#  hostname   :string           not null
#  status     :string           default("active")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_domains_on_name  (hostname) UNIQUE
#
module Domain
  class Name < ApplicationRecord
    include AASM

    has_many :records, class_name: 'Domain::Record', foreign_key: 'domain_name_id', dependent: :destroy

    validates :hostname, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUSES }

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
