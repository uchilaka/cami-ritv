# frozen_string_literal: true

# 20250504090802_rolify_create_accounts_roles.rb
class RolifyCreateAccountsRoles < ActiveRecord::Migration[8.0]
  def change
    create_table(:accounts_roles, id: false) do |t|
      t.references :account, type: :uuid
      t.references :role, type: :uuid
    end

    add_index(:accounts_roles, %i[account_id role_id])
  end
end
