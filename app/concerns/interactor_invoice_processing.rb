# frozen_string_literal: true

module InteractorInvoiceProcessing
  extend ActiveSupport::Concern

  included do
    include InteractorErrorHandling

    raise "#{name} requires Interactor" unless include?(Interactor)

    before do
      context.metadata[:invoice_number] = context.invoice&.invoice_number
      context.metadata[:options] = context.options || {}
    end
  end

  def require_invoice_record_presence!
    invoice = context.invoice
    return unless invoice.blank?

    invoice.errors.add :record, I18n.t('models.invoice.errors.record_missing', label: 'reference for invoice')
    context.errors += invoice.errors.full_messages
    raise LarCity::Errors::InvalidInvoiceRecord, invoice.errors.messages[:record]
  end

  def link_accounts?
    context.metadata.dig(:options, :link_accounts) || false
  end
end
