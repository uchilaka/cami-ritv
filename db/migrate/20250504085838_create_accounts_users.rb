# frozen_string_literal: true

# 20250504085838_create_accounts_users.rb
class CreateAccountsUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # this results in a join table :accounts_users with UUID FK columns account_id and user_id
    create_join_table :accounts, :users, column_options: { type: :uuid }, &:timestamps
    add_index :accounts_users, %i[account_id user_id], unique: true, if_not_exists: true, algorithm: :concurrently
  end
end
