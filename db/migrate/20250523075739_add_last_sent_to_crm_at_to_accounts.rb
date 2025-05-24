# frozen_string_literal: true

# 20250523075739
class AddLastSentToCrmAtToAccounts < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :accounts, :last_sent_to_crm_at, :datetime
    add_index :accounts, :last_sent_to_crm_at, algorithm: :concurrently
  end
end
