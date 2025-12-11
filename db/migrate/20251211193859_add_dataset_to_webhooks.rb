# frozen_string_literal: true

# 20251211193859
class AddDatasetToWebhooks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :webhooks, :dataset, :string, if_not_exists: true
    add_index :webhooks,
              %i[slug dataset],
              unique: true,
              algorithm: :concurrently,
              if_not_exists: true,
              where: 'dataset IS NOT NULL',
              name: 'index_webhooks_on_slug_and_dataset'
  end
end
