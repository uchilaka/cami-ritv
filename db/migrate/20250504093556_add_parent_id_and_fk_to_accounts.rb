# frozen_string_literal: true

# 20250504093556_add_parent_id_and_fk_to_accounts.rb
class AddParentIdAndFkToAccounts < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :accounts, :parent_id, :uuid
    add_foreign_key :accounts,
                    :accounts,
                    column: :parent_id, validate: false,
                    index: { algorithm: :concurrently }
  end
end
