# frozen_string_literal: true

module Notion
  module Vendors
    # @deprecated This class is deprecated in favor of Notion::PersistEventWorkflow
    #   which requires enabling the :feat__notion_use_persist_event_workflow feature flag
    #   and should be used to persist the event and its metadata. The processing
    #   of the event (e.g. creating/updating a vendor) should be a side effect of
    #   processing the persisted event, rather than being coupled with the persistence
    #   of the event itself.
    class UpsertEventWorkflow
      include Interactor

      def call
        entity = context.event.entity
        database = context.database
        remote_record_id = entity.id

        klass_type =
          case context.event.type
          when 'page.created'
            'Notion::VendorCreatedEvent'
          when 'page.properties_updated'
            'Notion::VendorUpdatedEvent'
          else
            message =
              I18n.t(
                'workflows.notion.upsert_event_workflow.errors.unsupported_event_type',
                event_type: context.event.type,
                workflow: self.class.name
              )
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
        # @TODO: Creating the (vendor) system event should enqueue the job to process the vendor as a side effect
        system_event = klass_type.constantize.create!(metadatum:)
        system_event.eventable = context.webhook
        if system_event.valid?
          system_event.save!
        else
          message = I18n.t(
            'workflows.notion.upsert_event_workflow.errors.invalid_event_data',
            workflow: self.class.name,
            event_type:
          )
          context.fail!(message:, errors: system_event.error.full_messages)
        end
      ensure
        context.result = system_event
        remote_event_id = context.event.id
        status = context.success? ? 'success' : 'failure'
        log_method = context.success? ? :info : :error
        log_message =
          I18n.t('workflows.notion.upsert_event_workflow.completed.log', status:, slug: system_event&.slug)
        Rails.logger.send(log_method, log_message, remote_event_id:, system_event: system_event&.serializable_hash)
      end
    end
  end
end
