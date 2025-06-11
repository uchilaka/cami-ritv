# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :uuid             not null, primary key
#  amount_cents              :integer          default(0), not null
#  amount_currency           :string           default("USD"), not null
#  discarded_at              :datetime
#  due_amount_cents          :integer          default(0), not null
#  due_amount_currency       :string           default("USD"), not null
#  due_at                    :datetime
#  invoice_number            :string
#  invoiceable_type          :string
#  invoicer                  :jsonb
#  issued_at                 :datetime
#  links                     :jsonb
#  metadata                  :jsonb
#  notes                     :text
#  paid_at                   :datetime
#  payment_vendor            :string
#  payments                  :jsonb
#  status                    :enum             default("draft")
#  type                      :string           default("Invoice")
#  updated_accounts_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invoiceable_id            :uuid
#  vendor_record_id          :string
#  vendor_recurring_group_id :string
#
# Indexes
#
#  index_invoices_on_discarded_at                         (discarded_at)
#  index_invoices_on_invoiceable                          (invoiceable_type,invoiceable_id)
#  index_invoices_on_invoiceable_type_and_invoiceable_id  (invoiceable_type,invoiceable_id)
#
Fabricator(:invoice) do
  payments               { [] }
  links                  { [] }
  payment_vendor         'paypal'
  # TODO: lookup what data ends up here from PayPal - this is intended as
  #   the contact info for user/vendor who generated the invoice
  invoicer               { { 'email' => Faker::Internet.email } }
  type                   'Invoice'
  updated_accounts_at    '2024-11-11 01:29:44'
  invoice_number         { sequence(:invoice_number) { |n| "INV-#{(n + 1).to_s.rjust(4, '0')}" } }
  issued_at              { Time.zone.now - 7.days }
  # due_at                 { Time.zone.now + 23.days }
  # paid_at                { Time.zone.now }
  # amount_cents           999
  # due_amount_cents       999

  after_build do |invoice|
    invoice.amount ||= '9.99'
    invoice.due_amount ||= invoice.amount
    invoice.issued_at ||= Time.zone.now - 7.days
    invoice.due_at ||= invoice.issued_at + 23.days
    invoice.paid_at ||= invoice.issued_at + 3.days if invoice.status == 'paid'
  end
end
