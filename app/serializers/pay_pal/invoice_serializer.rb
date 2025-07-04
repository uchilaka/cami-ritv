# frozen_string_literal: true

module PayPal
  class InvoiceSerializer < AdhocSerializer
    def attributes
      {
        vendor_record_id:,
        vendor_recurring_group_id:,
        invoice_number:,
        payment_vendor:,
        status:,
        invoicer:,
        issued_at:,
        due_at:,
        amount_cents:,
        amount_currency:,
        due_amount_cents:,
        due_amount_currency:,
        payments:,
        notes:,
        links:,
        metadata:
      }
    end

    def status
      object['status'].to_s.downcase
    end

    def vendor_record_id
      object['id']
    end

    def vendor_id
      vendor&.id
    end

    def vendor_recurring_group_id
      object['recurring_Id']
    end

    def invoice_number
      object.dig('detail', 'invoice_number')
    end

    def invoicer
      object['invoicer']&.symbolize_keys
    end

    def payment_vendor
      object['payment_vendor'] || 'paypal'
    end

    def amount
      serialize(object['amount'], to: 'Amount')
    end

    def amount_cents
      amount[:value_in_cents]
    end

    def amount_currency
      currency_code
    end

    def due_amount
      serialize(object['due_amount'], to: 'Amount')
    end

    def due_amount_cents
      due_amount[:value_in_cents]
    end

    def due_amount_currency
      currency_code
    end

    def payments
      paid_amount = object.dig('payments', 'paid_amount')
      return [] if paid_amount.blank?

      [serialize(paid_amount, to: 'Amount')]
    end

    def links
      object['links']
    end

    def issued_at
      object.dig('detail', 'invoice_date')
    end

    def due_at
      object.dig('detail', 'payment_term', 'due_date')
    end

    def viewed_by_recipient
      object.dig('detail', 'viewed_by_recipient')
    end

    def currency_code
      object.dig('detail', 'currency_code')
    end

    def notes
      object.dig('detail', 'note')
    end

    def accounts
      primary_recipients.map { |recipient| serialize(recipient, to: 'InvoiceAccount') }
    end

    def metadata
      {
        accounts:,
        amount:,
        due_amount:,
        vendor_id:,
        viewed_by_recipient:,
        response: {
          body: object,
          serialized_at: Time.zone.now.iso8601,
        }
      }
    end

    private

    def vendor
      @vendor ||= Account.find_by(slug: payment_vendor)
    end

    def primary_recipients
      object['primary_recipients'] || []
    end
  end
end
