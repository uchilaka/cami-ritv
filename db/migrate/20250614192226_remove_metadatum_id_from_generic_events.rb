# frozen_string_literal: true

# 20250614192226
class RemoveMetadatumIdFromGenericEvents < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :generic_events, :metadatum_id, :uuid, null: true
    end
  end
end
