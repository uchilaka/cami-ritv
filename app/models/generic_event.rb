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

  include Searchable

  friendly_id :id_last_5,
              use: :slugged,
              sequence_separator: '-',
              slug_limit: 10

  attribute :type, :string, default: 'GenericEvent'

  belongs_to :eventable, polymorphic: true, optional: true

  has_one :metadatum, as: :appendable, dependent: :destroy

  accepts_nested_attributes_for :metadatum

  delegate :remote_record_id, to: :metadatum, allow_nil: true

  validates :type, presence: true
  validates :metadatum, presence: true, if: -> { type != 'GenericEvent' }

  # FriendlyId helper methods
  # def slug_candidates
  #   [
  #     %i[id_first_5],
  #     %i[id_first_5 variant short_sha],
  #     %i[id_last_5 variant short_sha],
  #   ]
  # end

  def should_generate_new_friendly_id?
    slug.blank?
  end
  # End FriendlyId helper methods

  def eventable_slug
    eventable&.slug
  end

  def variant
    'generic'
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id slug status type eventable_id eventable_type created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[eventable appendable metadatum]
  end
end
