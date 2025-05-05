# frozen_string_literal: true

RSpec.shared_context 'for invoice testing', shared_context: :metadata do
  def sample_invoice_data
    @sample_invoice_data ||=
      YAML
        .load_file('spec/fixtures/paypal/fetch_invoices_sanitized.yml')
  end

  def sample_invoice_items
    sample_invoice_data['items'].map do |item|
      item['id'] = random_invoice_vendor_record_id
      item['detail']['invoice_number'] = random_invoice_number
      item
    end
  end

  def sample_invoice_dataset
    @sample_invoice_dataset ||= sample_invoice_items.map do |data|
      PayPal::InvoiceSerializer.new(data).serializable_hash
    end
  end

  # @deprecated this causes problems once we turn on validation of invoice number.
  #   Ideally, we should be using the invoice fabricators in each spec file or
  #   making sure we have a valid invoice number when loading the sample data
  def load_sample_invoice_dataset
    # Batch create all invoice records
    _results = Invoice.create!(sample_invoice_dataset)
    # Upsert all account records
    Sidekiq::Testing.inline! { UpsertInvoiceRecordsJob.perform_async }
  end
end
