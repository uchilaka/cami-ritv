# frozen_string_literal: true

# 20250503155807_create_anonymous_user.rb
class AddTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :type, :string, null: false, default: 'User'
  end
end
