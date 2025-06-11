# frozen_string_literal: true

# 20250611083051
class AddDiscardedAtToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # This migration adds a `discarded_at` column to the `users` table
  # to support soft deletion using the Discard gem.
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at, algorithm: :concurrently
  end
end
