# frozen_string_literal: true

# 20250611090542
class CreateWebhooks < ActiveRecord::Migration[8.0]
  def change
    create_table :webhooks, id: :uuid do |t|
      t.string :slug
      t.string :verification_token
      t.jsonb :data, default: {}

      t.timestamps
    end
    add_index :webhooks, :slug, unique: true
  end
end
