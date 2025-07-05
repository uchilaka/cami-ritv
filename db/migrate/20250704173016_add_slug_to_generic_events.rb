# frozen_string_literal: true

class AddSlugToGenericEvents < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :generic_events, :slug, :string, null: true
    add_index :generic_events, :slug, unique: true, algorithm: :concurrently
  end
end
