# frozen_string_literal: true

# 20250505130621
class AddOauthServerinfoIndexToMetadata < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :metadata,
              "((value->>'region_alpha2'))",
              using: :btree,
              if_not_exists: true,
              algorithm: :concurrently,
              name: 'index_for_zoho_oauth_serverinfo_metadata'
  end
end
