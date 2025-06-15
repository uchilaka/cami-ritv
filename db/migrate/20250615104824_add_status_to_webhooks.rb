# frozen_string_literal: true

# 20250615104824
class AddStatusToWebhooks < ActiveRecord::Migration[8.0]
  def change
    add_column :webhooks, :status, :string
    add_index :webhooks, :status

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
