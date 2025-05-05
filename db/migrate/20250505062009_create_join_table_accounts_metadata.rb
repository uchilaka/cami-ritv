# frozen_string_literal: true

# 20250505062009
class CreateJoinTableAccountsMetadata < ActiveRecord::Migration[8.0]
  def change
    create_join_table :accounts, :metadata, column_options: { type: :uuid } do |t|
      t.index %i[account_id metadatum_id], if_not_exists: true, unique: true
      t.timestamps
    end
  end
end
