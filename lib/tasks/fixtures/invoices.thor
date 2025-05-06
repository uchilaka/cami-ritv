# frozen_string_literal: true

require_relative '../../commands/lar_city/cli/base_cmd'

module Fixtures
  class Invoices < LarCity::CLI::BaseCmd
    attr_accessor :enqueued_records, :processed_records, :skipped_records, :error_records

    desc 'load', 'Load invoice fixtures'
    option :overwrite, type: :boolean, desc: 'Overwrite existing records', default: false
    def load
      say 'Loading invoice fixtures...', Color::YELLOW
      fixtures_to_load =
        if Invoice.none?
          tally = fixtures.count
          say "Found #{tally} #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures
        else
          fixtures_to_load = fixtures.reject { |b| record_exists?(b) }
          tally = fixtures_to_load.count
          say "Found #{tally} new #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures_to_load
        end
      return if fixtures_to_load.empty?

      ap fixtures_to_load if verbose?
      return if dry_run?

      # Process invoice records
      @enqueued_records = fixtures_to_load
      @processed_records = []
      # TODO: Implement a way to perform cherry-picked upserts for records that already exist
      @skipped_records = []
      @error_records = []

      @enqueued_records.each do |record|
        if (matching_record = record_exists?(record))
          if overwrite?
            Rails.logger.warn("Overwriting invoice record with ID #{record['id']}")
            matching_record.destroy
          else
            @skipped_records << record
            Rails.logger.warn("Skipping invoice record with ID #{record['id']} because it already exists", record:)
            next
          end
        end

        case vendor(record)
        when 'paypal'
          @processed_records << PayPal::InvoiceSerializer.new(record).serializable_hash
        else
          raise LarCity::Errors::Unsupported, "Vendor #{vendor(record)} is not supported"
        end
      rescue StandardError => e
        Rails.logger.error "#{self.class.name} invoice record(s) failed to process",
                           record:, message: e.message
        @error_records << record
      end

      Rails.logger.info "#{skipped_records.count} invoice records were skipped" if skipped_records.any?

      if @error_records.any?
        Rails.logger.error "#{error_records.count} invoice records that failed to process"
      else
        # TODO: Generate batch ID from starting page range and timestamp
        Rails.logger.info 'All enqueued invoice records were processed successfully'
      end

      # Batch create the records
      results = Invoice.create(@processed_records)

      if results.all?(&:valid?)
        Rails.logger.info "Saved #{things(results.count, with_count: true)}"
      else
        saved_records = results.reject { |record| record.errors.any? }
        Rails.logger.warn "Saved #{saved_records.count} of #{@processed_records.count} records"
        # IMPORTANT: Error records will now have contents that are either
        #   hashes or invalid instances of Invoice
        @error_records += results.select { |record| record.errors.any? }
        Rails.logger.error "Failed to save #{error_records.count} records"
      end

      return if results.none?(&:valid?)

      # Load invoice accounts
      results.each do |invoice|
        accounts = invoice.metadata['accounts']
        next if accounts.none?

        UpsertInvoiceRecordsWorkflow.call(invoice:, options: { link_accounts: true })
      end
    end

    protected

    def things(count, with_count: false)
      pluralized = 'invoice'.pluralize(count)
      return "#{count} #{pluralized}" if with_count

      pluralized
    end

    private

    def overwrite?
      options[:overwrite]
    end

    def record_exists?(record)
      if Invoice.exists?(vendor_record_id: record['id'])
        return Invoice.find_by_vendor_record_id(record['id']) if overwrite?

        return true
      end

      if Invoice.exists?(invoice_number: record.dig('detail', 'invoice_number'))
        return Invoice.find_by_invoice_number(record.dig('detail', 'invoice_number')) if overwrite?

        return true
      end

      false
    end

    def vendor(_record)
      'paypal'
    end

    def fixtures
      @fixtures ||= YAML.load(
        ERB.new(
          File.read(Rails.root.join('spec/fixtures/paypal/fetch_invoices_sanitized.yml').to_s)
        ).result
      )['items'].map do |b|
        b = b.with_indifferent_access
        b
      end
    end
  end
end
