# == Schema Information
#
# Table name: generic_events
#
#  id             :uuid             not null, primary key
#  eventable_type :string
#  status         :string
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eventable_id   :uuid
#  metadatum_id   :uuid
#
# Indexes
#
#  index_generic_events_on_eventable     (eventable_type,eventable_id)
#  index_generic_events_on_metadatum_id  (metadatum_id)
#
# Foreign Keys
#
#  fk_rails_...  (metadatum_id => metadata.id)
#
class GenericEvent < ApplicationRecord
  attribute :type, :string, default: 'GenericEvent'

  belongs_to :eventable, polymorphic: true, optional: true
end
