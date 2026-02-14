# frozen_string_literal: true

# 20251211203859
class AddVendorAccountIdToWebhooks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :webhooks,
               :vendor_account_id, :uuid,
               if_not_exists: true
  end
end
