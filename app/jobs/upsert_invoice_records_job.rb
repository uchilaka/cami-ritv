# frozen_string_literal: true

class UpsertInvoiceRecordsJob < ApplicationJob
  queue_as server_queue_name

  retry_on StandardError, wait: 15.seconds, attempts: 3

  BATCH_LIMIT = 25

  def perform
    # TODO: Explore using Sidekiq's built-in batch processing features for UpsertInvoiceRecordsJob
    Invoice
      .where(updated_accounts_at: nil)
      .limit(batch_limit)
      .each do |invoice|
      next if invoice.metadata['accounts']&.none?

      options = { link_accounts: true }
      UpsertInvoiceRecordsWorkflow.call(invoice:, options:)
    end
  end

  def recurring_invoice_url(url)
    "https://www.paypal.com/invoice/s/recurring/details/#{url}"
  end

  def batch_limit
    ENV.fetch('UPSERT_INVOICE_BATCH_LIMIT', BATCH_LIMIT).to_i
  end
end
