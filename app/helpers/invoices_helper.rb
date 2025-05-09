# frozen_string_literal: true

module InvoicesHelper
  def currency_code_options
    Money::Currency.all.map { |code| [code.name, code.iso_code] }
  end

  def invoice_status_options
    [
      ['Draft', 'draft'],
      ['Sent', 'sent'],
      ['Scheduled', 'scheduled'],
      ['Unpaid', 'unpaid'],
      ['Canceled', 'cancelled'],
      ['Payment pending', 'payment_pending'],
      ['Marked as paid', 'marked_as_paid'],
      ['Partially paid', 'partially_paid'],
      ['Paid', 'paid'],
      ['Marked as refunded', 'marked_as_refunded'],
      ['Partially refunded', 'partially_refunded'],
      ['Refunded', 'refunded']
    ]
  end

  def invoice_filtering_enabled?
    Flipper.enabled?(:feat__invoice_filtering)
  end

  def due_date_filter_options
    [
      ['Past due 7 days', 'past_due_7_days'],
      ['Past due 30 days', 'past_due_30_days'],
      ['Past due later', 'past_due_later_than_30_days'],
      ['Due today', 'due_today'],
      ['Due this week', 'due_this_week'],
      ['Due this month', 'due_this_month'],
      ['Due next month', 'due_next_month'],
      ['Due later', 'due_later_than_next_month']
    ]
  end

  def invoice_status_filter_options
    [
      %w[Draft DRAFT],
      %w[Sent SENT],
      %w[Paid PAID],
      ['Partially paid', 'PARTIALLY_PAID'],
      %w[Canceled CANCELLED]
    ]
  end
end
