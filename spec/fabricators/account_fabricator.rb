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
require 'phonelib'

Fabricator(:account) do
  transient             :phone_number
  transient             :country_alpha2
  transient             :users

  display_name          { Faker::Company.name }
  email                 { Faker::Internet.email }
  slug                  { SecureRandom.alphanumeric(4).downcase }
  tax_id                { Faker::Company.ein }
  type                  'Account'
  status                'draft'

  phone do |attrs|
    phone_input = attrs[:phone_number] || '+2347129248348'
    country_alpha2 =
      if attrs[:phone_number].present?
        attrs[:country_alpha2]
      else
        'NG'
      end
    phone_number = Phonelib.parse(phone_input, country_alpha2)
    intersect_types = PhoneNumber.supported_types.intersection phone_number.types
    number_type = intersect_types.any? ? intersect_types.first : phone_number.types.first
    full_e164 = phone_number.full_e164
    { country: phone_number.country, full_e164:, number_type: }
  end

  # TODO: Should not need to handle users transiently, since active record
  #   should just work when the users array argument is provided 🤞🏾
  after_create do |account, transients|
    if transients[:users].is_a?(Array)
      transients[:users].each do |user|
        account.users << user
      end
    end
  end
end

Fabricator(:account_with_invoices, from: :account) do
  transient :invoices

  after_build do |account, transients|
    if transients[:invoices].is_a?(Array)
      transients[:invoices].each do |invoice|
        account.add_role(:customer, invoice.record)
      end
    end
  end
end
