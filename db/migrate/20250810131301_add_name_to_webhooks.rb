# frozen_string_literal: true

# 20250810131301
class AddNameToWebhooks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :webhooks, :name, :string
    add_index :webhooks, :name, unique: true, algorithm: :concurrently
    Webhook.reset_column_information
  end
end
