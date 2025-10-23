# frozen_string_literal: true

module Notion
  class HandlePageEventWorkflow
    include Interactor

    def call
      event = context.event
      if event.blank?
        context.fail!(I18n.t('workflows.handle_notion_page_event_workflow.errors.invalid_or_missing_event'))
        return
      end

      webhook = context.webhook
      context.response_http_status =
        case event.type
        when 'page.created', 'page.properties_updated', 'page.deleted'
          page = event.entity
          database = event.parent.type == 'database' ? event.parent : nil

          case database&.id
          when webhook.data['deal_database_id']
            # Proceed
            result = ::Notion::Deals::UpsertEventWorkflow.call(event:, webhook:, database:)
            if result.success?
              :ok
            else
              Rails.logger.error(
                "Failed to process Notion event: #{event.type}",
                error: result.error,
                event: event.serializable_hash
              )
              :server_error
            end
          else
            Rails.logger.warn(
              "Unhandled notion #{event.type} event for parent type #{event.parent.type}",
              event.serializable_hash
            )
            :unprocessable_entity
          end
        else
          Rails.logger.warn("Unhandled notion #{event.type} event", event.serializable_hash)
          :unprocessable_entity
        end
    ensure
      status = context.success? ? 'succeeded' : 'failed'
      message =
        I18n.t('workflows.handle_notion_page_event_workflow.completed.log',
               event_type: event.type, page: page&.id, status:)
      Rails.logger.info(message, event: event.serializable_hash)
    end
  end
end
