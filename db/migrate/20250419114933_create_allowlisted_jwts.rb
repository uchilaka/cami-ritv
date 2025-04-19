# 20250419114933_create_allowlisted_jwts.rb
class CreateAllowlistedJwts < ActiveRecord::Migration[8.0]
  def change
    # Docs on the Allowlist JWT Revocation Strategy: https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#allowlist
    create_table :allowlisted_jwts, id: :uuid do |t|
      t.string :jti, null: false
      t.string :aud
      # If you want to leverage the `aud` claim, add to it a `NOT NULL` constraint:
      # t.string :aud, null: false
      t.datetime :exp, null: false
      t.references :user, foreign_key: { on_delete: :cascade }, type: :uuid, null: false
    end

    add_index :allowlisted_jwts, :jti, unique: true
  end
end
