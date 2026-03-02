# frozen_string_literal: true

class CreateDomainRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_records, id: :uuid do |t|
      t.references :domain_name, foreign_key: true, type: :uuid, null: false
      t.string :type, null: false
      t.string :vendor_record_id # e.g. the ID from the DNS provider, for tracking and updates
      t.string :name # e.g. the subdomain part, like 'www' or '@'
      t.string :value, null: false # e.g. the IP address or CNAME target
      t.integer :priority # for MX records
      t.integer :ttl, default: 1800 # default TTL of 30 minutes
      t.string :status, default: 'active' # e.g. 'active', 'pending', 'error'

      t.index %i[domain_name_id name type],
              name: 'index_domain_records_on_domain_and_name_and_type'
      t.index :vendor_record_id

      t.timestamps
    end
  end
end
