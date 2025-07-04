# frozen_string_literal: true

# 20250611083108
class AddDiscardedAtToInvoices < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # This migration adds a `discarded_at` column to the `invoices` table
  # to support soft deletion using the Discard gem.
  #
  # The `discarded_at` column will store the timestamp when an invoice is discarded.
  # An index is added on this column to optimize queries that filter by discarded status.
  def change
    add_column :invoices, :discarded_at, :datetime
    add_index :invoices, :discarded_at, algorithm: :concurrently
  end
end
