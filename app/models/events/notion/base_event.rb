# frozen_string_literal: true

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
module Notion
  class BaseEvent < ::GenericEvent
    # @serializer_klass = nil
    #
    # class << self
    #   def set_serializer_klass(klass)
    #     @serializer_klass = klass
    #   end
    #
    #   def serializer_klass
    #     @serializer_klass ||= "#{name}Serializer".constantize
    #   end
    # end

    include AASM

    delegate :variant,
             :entity_id,
             :integration_id,
             :remote_record_id,
             :database_id,
             :workspace_id,
             :workspace_name,
             :attempt_number,
             :database,
             :entity, to: :metadatum

    has_one :payload, as: :appendable, class_name: 'Notion::WebhookEventMetadatum'

    alias webhook eventable

    aasm column: :status do
      state :pending, initial: true
      state :processing
      state :completed
      state :failed

      event :process do
        transitions from: :pending, to: :processing
      end

      event :complete do
        transitions from: :processing, to: :completed
      end

      event :fail do
        transitions from: %i[pending processing], to: :failed
      end
    end

    after_commit :pull_remote_record, on: %i[create update]

    def pull_remote_record
      return unless Flipper.enabled?(:feat__notion_async_fetch_deal)

      Notion::FetchDealJob.perform_later(
        webhook_slug: eventable.slug,
        remote_record_id:
      )
    end

    def variant
      return nil if metadatum.blank?

      metadatum.key.split('.').last
    end
  end
end
