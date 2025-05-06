# frozen_string_literal: true

# 20250504090802_rolify_create_accounts_roles.rb
class RolifyCreateAccountsRoles < ActiveRecord::Migration[8.0]
  def change
    create_table(:accounts_roles, id: false) do |t|
      t.belongs_to :role, foreign_key: true, type: :uuid
      t.belongs_to :account, foreign_key: true, type: :uuid
    end
  end
end
