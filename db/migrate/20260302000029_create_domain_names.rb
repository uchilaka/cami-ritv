# frozen_string_literal: true

class CreateDomainNames < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_names, id: :uuid do |t|
      t.string :hostname, null: false
      t.string :status, default: 'active' # e.g. 'active', 'pending', 'error'

      t.index :hostname, name: 'index_domains_on_name', unique: true

      t.timestamps
    end
  end
end
