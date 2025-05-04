# frozen_string_literal: true

# 20250504144509
class CreateInvoices < ActiveRecord::Migration[8.0]
  def up
    create_enum :invoice_status,
                %w[
                  draft
                  sent
                  scheduled
                  unpaid
                  cancelled
                  payment_pending
                  marked_as_paid
                  partially_paid
                  paid
                  marked_as_refunded
                  partially_refunded
                  refunded
                ]

    create_table :invoices, id: :uuid do |t|
      t.belongs_to :invoiceable, polymorphic: true, type: :uuid
      t.string :vendor_record_id
      t.string :vendor_recurring_group_id
      t.string :invoice_number
      t.string :payment_vendor
      t.enum :status, default: :draft, enum_type: :invoice_status
      t.timestamp :issued_at
      # t.timestamp :viewed_by_recipient_at # TODO Figure out queries of paper_trail data instead for this
      t.timestamp :updated_accounts_at
      t.timestamp :due_at
      t.timestamp :paid_at
      t.monetize :amount
      t.monetize :due_amount
      t.text :notes
      t.jsonb :payments
      t.jsonb :links

      t.timestamps
    end

    add_index :invoices, %i[invoiceable_type invoiceable_id]
  end

  def down
    remove_index :invoices,
                 %i[invoiceable_type invoiceable_id],
                 name: 'index_invoices_on_invoiceable', if_exists: true
    remove_index :invoices,
                 %i[invoiceable_type invoiceable_id],
                 name: 'index_invoices_on_invoiceable_type_and_invoiceable_id', if_exists: true
    drop_table :invoices
    drop_enum :invoice_status
  end
end
