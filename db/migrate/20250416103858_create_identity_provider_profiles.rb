# frozen_string_literal: true

# 20250416103858_create_identity_provider_profiles.rb
class CreateIdentityProviderProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :identity_provider_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :uid
      t.string :provider
      t.string :email
      t.boolean :verified, default: false
      t.string :given_name, default: ''
      t.string :family_name, default: ''
      t.string :display_name
      t.string :image_url
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :identity_provider_profiles,
              %i[user_id provider],
              unique: true, if_not_exists: true
    add_index :identity_provider_profiles,
              %i[uid provider],
              unique: true, if_not_exists: true
    add_index :identity_provider_profiles,
              %i[email provider],
              unique: true, if_not_exists: true
  end
end
