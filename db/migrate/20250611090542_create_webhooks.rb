class CreateWebhooks < ActiveRecord::Migration[8.0]
  def change
    create_table :webhooks, id: :uuid do |t|
      t.string :url
      t.string :verification_token

      t.timestamps
    end
  end
end
