# frozen_string_literal: true

class SetSlugForExistingEvents < ActiveRecord::Migration[8.0]
  def up
    GenericEvent.find_each do |event|
      event.touch if event.slug.blank?
      event.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
