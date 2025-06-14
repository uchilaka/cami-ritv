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
Fabricator(:generic_event) do
  transient :integration
end

Fabricator(:deal_created_event, from: :generic_event) do
  metadatum { Fabricate(:metadatum, key: 'deal_created') }
  status { 'pending' }

  type do |attrs|
    if attrs[:integration] == :notion
      'Notion::DealCreatedEvent'
    else
      'Generic::DealCreatedEvent'
    end
  end

  integration do |attrs|
    if attrs[:integration].present?
      attrs[:integration]
    elsif /^Notion::/.match?(attrs[:type])
      :notion
    end
  end
end
