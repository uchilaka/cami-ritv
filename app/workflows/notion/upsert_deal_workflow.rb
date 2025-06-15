# frozen_string_literal: true

module Notion
  class UpsertDealWorkflow
    include Interactor

    def call
      entity = context.event.entity
      database = context.event.parent
      remote_record_id = entity.id

      klass_type =
        case context.event.type
        when 'page.created'
          'Notion::DealCreatedEvent'
        when 'page.properties_updated'
          'Notion::DealUpdatedEvent'
        else
          error =
            I18n.t('workflows.upsert_deal_workflow.errors.unsupported_event_type', event_type: context.event.type)
          fail!(error:)
        end
      return if context.failed?

      event_data = {
        remote_record_id:,
        database: database.serializable_hash,
        entity: entity.serializable_hash,
        **context.event.serializable_hash,
      }
      metadatum = ::Notion::WebhookEventMetadatum.create!(key: "notion.#{context.event.type}", value: event_data)
      system_event = klass_type.constantize.create!(metadatum:)
      system_event.eventable = context.webhook
      if system_event.valid?
        system_event.save!
      else
        fail!(error: system_event.error.full_messages)
      end
    ensure
      remote_event_id = context.event.id
      status = context.success? ? 'success' : 'failure'
      log_message =
        I18n.t('workflows.upsert_deal_workflow.completed.log', status:, slug: 'fake-deal-slug')
      Rails.logger.info(log_message, remote_event_id:, system_event: system_event&.serializable_hash)
    end
  end
end
