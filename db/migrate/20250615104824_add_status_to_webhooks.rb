# frozen_string_literal: true

# 20250615104824
class AddStatusToWebhooks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :webhooks, :status, :string,
               null: false, default: 'pending_review', if_not_exists: true
    add_index :webhooks, :status, algorithm: :concurrently, if_not_exists: true

    # reversible do |dir|
    #   dir.up do
    #     # Set the status to 'active' for existing webhooks
    #     Webhook.update_all(status: 'active')
    #   end
    #
    #   dir.down do
    #     # No action needed on down migration
    #   end
    # end
  end
end
