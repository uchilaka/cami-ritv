# == Schema Information
#
# Table name: generic_events
#
#  id             :uuid             not null, primary key
#  eventable_type :string
#  slug           :string
#  status         :string
#  type           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eventable_id   :uuid
#
# Indexes
#
#  index_generic_events_on_eventable  (eventable_type,eventable_id)
#  index_generic_events_on_slug       (slug) UNIQUE
#
class GenericEvent < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged, slug_limit: 15

  attribute :type, :string, default: 'GenericEvent'

  belongs_to :eventable, polymorphic: true, optional: true

  has_one :metadatum, as: :appendable, dependent: :destroy

  accepts_nested_attributes_for :metadatum

  delegate :remote_record_id, to: :metadatum, allow_nil: true

  validates :metadatum, presence: true, if: -> { type != 'GenericEvent' }

  # FriendlyId helper methods
  def slug_candidates
    [
      %i[eventable_slug id],
      %i[eventable_slug variant id],
    ]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
  # End FriendlyId helper methods

  def eventable_slug
    eventable.slug
  end

  def variant
    raise NotImplementedError,
          'Subclasses must implement #variant'
  end
end
