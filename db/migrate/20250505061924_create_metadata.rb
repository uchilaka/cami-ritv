# frozen_string_literal: true

# 20250505061924
class CreateMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata, id: :uuid do |t|
      t.string :key, null: false
      t.string :type, null: false, default: 'Metadatum'
      t.jsonb :value, default: {}
      t.timestamps
    end
  end
end
