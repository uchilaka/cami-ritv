# frozen_string_literal: true

# 20250825125426
class CreateDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :deals, id: :uuid do |t|
      t.references :account, foreign_key: true, type: :uuid
      t.money :amount
      t.timestamp :expected_close_at
      t.timestamp :last_contacted_at
      t.string :priority
      t.string :stage, null: false, default: 'discovery'
      t.string :type, null: false, default: 'Deal'

      t.timestamps
    end
  end
end
