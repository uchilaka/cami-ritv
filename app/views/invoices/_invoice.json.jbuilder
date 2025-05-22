# frozen_string_literal: true

json.extract! invoice.serializable_hash, :id, :account, :payment_vendor,
              :payments, :links, :viewed_by_recipient_at, :updated_accounts_at, :invoice_number,
              :status, :issued_at, :due_at, :paid_at, :amount, :due_amount, :currency_code, :notes,
              :created_at, :updated_at, :actions
json.number invoice.invoice_number
json.contacts invoice.metadata['accounts']
json.is_recurring invoice.recurring?
json.tooltip_id record_dom_id(invoice, prefix: 'tooltip-filter')
# json.item_action_btn_classes = default_item_action_btn_classes

json.url invoice_url(invoice, format: :json)
json.recurring_details_url invoice.recurring_details_url if invoice.vendor_recurring_group_id.present?
json.payment_vendor_url invoice.payment_vendor_url

json.is_past_due invoice.past_due?
json.is_overdue invoice.overdue?
