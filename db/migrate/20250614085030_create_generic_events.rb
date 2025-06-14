class CreateGenericEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :generic_events, id: :uuid do |t|
      t.string :type
      t.uuid :eventable_id
      t.string :eventable_type
      t.references :metadatum, type: :uuid, foreign_key: true

      t.timestamps
    end
    add_index :generic_events, %i[eventable_type eventable_id], name: 'index_generic_events_on_eventable'
  end
end
