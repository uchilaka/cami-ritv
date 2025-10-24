# frozen_string_literal: true

module Notion
  class UpsertEventWorkflow
    include Interactor

    delegate :database_type,
             :klass_type,
             :webhook,
             :event,
             :database, to: :context

    def call
      entity = event.entity
      remote_record_id = entity.id
      event_klass = klass_type.constantize
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
      metadatum = ::Notion::WebhookEventMetadatum.create!(key: "notion.#{event.type}", value: event_data)
      # TODO: Creating the (deal) system event should enqueue the job to process the deal as a side effect
      system_event = event_klass.create!(metadatum:)
      system_event.eventable = context.webhook
      if system_event.valid?
        system_event.save!
      else
        message = I18n.t(
          'workflows.notion.upsert_event_workflow.errors.invalid_event_data',
          event_type: event.type, workflow: self.class.name
        )
        context.fail!(message:, errors: system_event.error.full_messages)
      end
    ensure
      context.result = system_event
      remote_event_id = event.id
      status = context.success? ? 'success' : 'failure'
      log_message =
        I18n.t(
          'workflows.notion.upsert_event_workflow.completed.log',
          status:, id: event.id, event_type: event.type, workspace: event.workspace_name
        )
      Rails.logger.info(log_message, remote_event_id:, system_event: system_event.serializable_hash)
    end
  end
end
