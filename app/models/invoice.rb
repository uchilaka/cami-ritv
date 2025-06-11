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
class Invoice < ApplicationRecord
  resourcify

  include AASM
  include Actionable
  include Discard::Model
  include Renderable
  include Searchable

  supported_actions :show

  has_rich_text :notes

  # TODO: Refactor amount fields to *_in_cents
  monetize :amount_cents
  monetize :due_amount_cents

  attribute :payment_vendor, :string
  attribute :metadata, :jsonb, default: { accounts: [] }

  PAYPAL_BASE_URL = ENV.fetch('PAYPAL_BASE_URL', Rails.application.credentials.paypal&.base_url).freeze

  has_many :roles, as: :resource, dependent: :destroy

  # TODO: Validate on update that the invoiceable is an Account or User
  belongs_to :invoiceable, polymorphic: true, optional: true

  validates :invoice_number, presence: true, uniqueness: { case_sensitive: false }
  validates :payment_vendor,
            presence: true,
            inclusion: { in: %w[paypal] }
  validates :amount_currency,
            allow_nil: true,
            inclusion: { in: Money::Currency.all.map(&:iso_code) }
  validates :due_amount_currency,
            allow_nil: true,
            inclusion: { in: Money::Currency.all.map(&:iso_code) }
  validates :amount_cents, presence: true
  # TODO: Validate that due_at is after issued_at
  # TODO: Validate that due_amount_cents is less than or equal to amount_cents

  # Payment vendor documentation for invoice status:
  # https://developer.paypal.com/docs/api/invoicing/v2/#definition-invoice_status
  aasm column: :status, logger: Rails.logger do
    state :draft, initial: true
    state :sent
    state :scheduled
    state :unpaid
    state :cancelled
    state :payment_pending
    state :partially_paid
    state :marked_as_paid
    state :paid
    state :marked_as_refunded
    state :partially_refunded
    state :refunded

    # TODO: Should require invoiceable (with confirmed email address) to send bill
    event :send_bill do
      transitions from: %i[draft scheduled], to: :sent
    end

    event :partial_payment do
      transitions from: %i[draft sent scheduled unpaid payment_pending partially_paid], to: :partially_paid
    end

    event :paid_in_full do
      transitions from: %i[draft sent scheduled unpaid payment_pending partially_paid], to: :paid
    end

    event :paid_via_transfer do
      transitions from: %i[draft sent scheduled unpaid payment_pending partially_paid], to: :marked_as_paid
    end

    event :late_payment_30_days do
      # TODO: Mark as unpaid with payment provider
      transitions from: %i[sent scheduled unpaid payment_pending], to: :unpaid
    end

    event :late_payment_90_days do
      # TODO: Mark as canceled with payment provider
      transitions from: %i[sent scheduled unpaid payment_pending], to: :unpaid
    end
  end

  def payment_vendor_url
    case payment_vendor
    when 'paypal'
      "#{PAYPAL_BASE_URL}/invoice/s/details/#{vendor_record_id}"
    else
      ''
    end
  end

  def recurring_details_url
    case payment_vendor
    when 'paypal'
      "#{PAYPAL_BASE_URL}/invoice/s/recurring/details/#{vendor_recurring_group_id}"
    else
      ''
    end
  end

  def resource_url(_, args = {})
    url_method_name = args[:action] == :show ? :show_modal_invoice_url : :invoice_url
    args.merge!(protocol: :https) if AppUtils.use_secure_protocol?
    send(url_method_name, self, **args)
  end

  # @deprecated Use `amount_currency` or `due_amount_currency` instead
  def currency_code
    amount_currency
  end

  # @deprecated Use assignment to `amount_currency` or `due_amount_currency` instead
  def currency_code=(currency_code)
    self.amount_currency ||= currency_code
    self.due_amount_currency ||= currency_code
  end

  def account=(account)
    self.invoiceable = account
  end

  def account
    invoiceable if invoiceable.is_a?(Account)
  end

  def recurring?
    vendor_recurring_group_id.present?
  end

  def past_due?
    !paid? && due_at.to_date < Time.zone.now.to_date
  end

  def overdue?
    past_due? && (Time.zone.now.to_date - due_at.to_date).to_i > 30
  end

  def editable?
    !(paid? || refunded?)
  end

  # Class methods
  def self.ransackable_attributes(_auth_object = nil)
    %w[amount_cents created_at due_amount_cents due_at invoice_number status]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[invoiceable action_rich_text]
  end
end
