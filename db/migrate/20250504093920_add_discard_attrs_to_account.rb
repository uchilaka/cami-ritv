# frozen_string_literal: true

# 20250504093920_add_discard_attrs_to_account.rb
class AddDiscardAttrsToAccount < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :accounts, :discarded_at, :datetime
    add_index :accounts, :discarded_at, algorithm: :concurrently
  end
end
