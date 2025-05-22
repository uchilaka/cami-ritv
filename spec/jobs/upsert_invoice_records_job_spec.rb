# frozen_string_literal: true

require 'rails_helper'

# Jobs testing guide: https://guides.rubyonrails.org/testing.html#testing-jobs
RSpec.describe UpsertInvoiceRecordsJob, type: :job do
  let(:invoice_data) { YAML.load_file('spec/fixtures/paypal/fetch_invoices_sanitized.yml') }
  let(:items) { invoice_data['items'] }

  before do
    dataset = items.map { |data| PayPal::InvoiceSerializer.new(data).serializable_hash }
    # Batch create all invoice records
    Invoice.create(dataset)
  end

  describe '#perform' do
    let(:batch_limit) { described_class::BATCH_LIMIT }

    around do |example|
      # Intentionally NOT using Sidekiq::Testing.inline! so we can assert that the job is enqueued
      with_modified_env(UPSERT_INVOICE_BATCH_LIMIT: batch_limit.to_s) { example.run }
    end

    context 'with incoming records within the batch limit' do
      let(:batch_limit) { 9_999 }

      it 'creates the expected tally of new account records' do
        expect do
          described_class.perform_later
          perform_enqueued_jobs
        end.to change(Account, :count).by(19)
      end
    end

    context 'with incoming records exceeding the batch limit' do
      let(:batch_limit) { 5 }

      it 'creates the expected tally of new account records' do
        expect do
          described_class.perform_later
          perform_enqueued_jobs
        end.to change(Account, :count).by(3)
      end
    end
  end
end
