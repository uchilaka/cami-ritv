# frozen_string_literal: true

# 20250504093722_add_index_by_email_to_acconts.rb
class AddIndexByEmailToAcconts < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # Create partial index on email
    add_index :accounts,
              :email,
              unique: true,
              nulls_not_distinct: true,
              # TODO: Do we need to check for empty string for partial indexes
              #   if we're using :nulls_not_distinct?
              where: 'email IS NOT NULL',
              name: 'by_account_email_if_set',
              algorithm: :concurrently
  end

  def down
    remove_index :accounts, name: 'by_account_email_if_set', if_exists: true
  end
end
