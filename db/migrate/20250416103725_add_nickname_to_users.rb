# frozen_string_literal: true

# 20250416103725_add_nickname_to_users.rb
class AddNicknameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :nickname, :string
  end
end
