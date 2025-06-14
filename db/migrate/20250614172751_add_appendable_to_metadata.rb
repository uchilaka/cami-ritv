# frozen_string_literal: true

# 20250614172751
class AddAppendableToMetadata < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :metadata,
                  :appendable,
                  polymorphic: true, type: :uuid,
                  index: { algorithm: :concurrently, name: 'index_metadata_on_appendable' },
                  if_not_exists: true
  end
end
