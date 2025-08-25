# frozen_string_literal: true

module Notion
  class UpsertDealEventWorkflow
    include Interactor

    def call
      entity = context.event.entity
      database = context.database
      remote_record_id = entity.id

      klass_type =
        case context.event.type
        when 'page.created'
          'Notion::DealCreatedEvent'
        when 'page.properties_updated'
          'Notion::DealUpdatedEvent'
        else
          message =
            I18n.t('workflows.upsert_notion_deal_workflow.errors.unsupported_event_type', event_type: context.event.type)
          context.fail!(message:)
        end
      return if context.failure?

      event_type, timestamp, workspace_id, workspace_name, integration_id, attempt_number =
        context
          .event
          .serializable_hash
          .values_at('type', 'timestamp', 'workspace_id', 'workspace_name', 'integration_id', 'attempt_number')
      event_data = {
        database: database.serializable_hash,
        entity: entity.serializable_hash,
        type: event_type,
        timestamp:,
        remote_record_id:,
        workspace_id:,
        workspace_name:,
        integration_id:,
        attempt_number:,
      }
      metadatum = ::Notion::WebhookEventMetadatum.create!(key: "notion.#{context.event.type}", value: event_data)
      # TODO: Creating the (deal) system event should enqueue the job to process the deal as a side effect
      system_event = klass_type.constantize.create!(metadatum:)
      system_event.eventable = context.webhook
      if system_event.valid?
        system_event.save!
      else
        message = I18n.t(
          'workflows.upsert_notion_deal_workflow.errors.invalid_event_data',
          event_type:
        )
        context.fail!(message:, errors: system_event.error.full_messages)
      end
    ensure
      remote_event_id = context.event.id
      status = context.success? ? 'success' : 'failure'
      log_message =
        I18n.t('workflows.upsert_notion_deal_workflow.completed.log', status:, slug: 'fake-deal-slug')
      Rails.logger.info(log_message, remote_event_id:, system_event: system_event&.serializable_hash)
    end
  end
end
