# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :uuid             not null, primary key
#  amount_cents              :integer          default(0), not null
#  amount_currency           :string           default("USD"), not null
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
#  index_invoices_on_invoiceable                          (invoiceable_type,invoiceable_id)
#  index_invoices_on_invoiceable_type_and_invoiceable_id  (invoiceable_type,invoiceable_id)
#
class InvoiceSerializer < ActiveModel::Serializer
  attributes :id,
             :vendor_record_id,
             :vendor_recurring_group_id,
             :invoice_number,
             :status,
             :invoicer,
             :account,
             :payments,
             :payment_vendor,
             :viewed_by_recipient,
             :viewed_by_recipient_at,
             :updated_accounts_at,
             :created_at,
             :updated_at,
             :issued_at,
             :due_at,
             :paid_at,
             :currency_code,
             :amount,
             :due_amount,
             :links,
             :notes,
             :actions

  def id
    object.id.to_s
  end

  def amount
    value = object.amount
    return if value.blank?

    MonetaryValueSerializer.new(value).serializable_hash
  end

  def due_amount
    value = object.due_amount
    return if value.blank?

    MonetaryValueSerializer.new(value).serializable_hash
  end

  def account
    return unless object.invoiceable_type == 'Account'

    object.invoiceable.serializable_hash
  end

  def user
    object.invoiceable if object.invoiceable_type == 'User'
  end

  def currency_code
    object.amount_currency
  end

  def status
    object.status.upcase
  end

  def viewed_by_recipient
    object.metadata['viewed_by_recipient']
  end

  def viewed_by_recipient_at
    nil
  end

  def notes
    ''
  end

  def actions
    object.actions
  end
end
