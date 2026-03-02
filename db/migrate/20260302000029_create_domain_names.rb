# frozen_string_literal: true

class CreateDomainNames < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_names, id: :uuid do |t|
      t.references :vendor, type: :uuid, foreign_key: { to_table: :accounts }
      t.string :hostname, null: false
      t.string :status, default: 'pending' # e.g. 'active', 'pending', 'error'

      t.index :hostname, name: 'index_domains_on_name', unique: true

      t.timestamps
    end
  end
end
