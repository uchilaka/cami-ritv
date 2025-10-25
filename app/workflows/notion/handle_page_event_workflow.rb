# frozen_string_literal: true

module Notion
  class HandlePageEventWorkflow
    include Interactor

    delegate :database, :event, :webhook, to: :context

    def self.page_event_class_mapping
      {
        deals: {
          'page.created' => 'Notion::DealCreatedEvent',
          'page.properties_updated' => 'Notion::DealUpdatedEvent',
          # 'page.deleted' => 'Notion::DealDeletedEvent',
        },
        vendors: {
          'page.created' => 'Notion::VendorCreatedEvent',
          'page.properties_updated' => 'Notion::VendorUpdatedEvent',
          # 'page.deleted' => 'Notion::VendorDeletedEvent',
        },
      }
    end

    def call
      if event.blank?
        context.fail!(I18n.t('workflows.handle_notion_page_event_workflow.errors.invalid_or_missing_event'))
        return
      end

      # Ensure event type is supported
      return :unprocessable_entity unless event_type_supported?

      # Set database based on event parent before any further processing
      context.database = event.parent.type == 'database' ? event.parent : nil

      if Flipper.enabled?(:feat__notion_use_upsert_event_workflow_v2)
        context.response_http_status =
          begin
            workflow = PersistEventWorkflow.call(event:, webhook:, database:, database_type:, klass_type:)
            if workflow.success?
              :ok
            else
              Rails.logger.error(
                "Failed to process Notion event: #{event.type}",
                error: workflow.error,
                event: event.serializable_hash
              )
              500
            end
          end
      else
        context.response_http_status =
          case event.type
          when 'page.created', 'page.properties_updated', 'page.deleted'
            page = event.entity
            case database&.id
            when webhook.data['deal_database_id']
              # Proceed
              workflow = ::Notion::Deals::UpsertEventWorkflow.call(event:, webhook:, database:)
              if workflow.success?
                :ok
              else
                Rails.logger.error(
                  "Failed to process Notion event: #{event.type}",
                  error: workflow.error,
                  event: event.serializable_hash
                )
                500
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
      end
    rescue NotImplementedError => e
      Rails.logger.error('Failed to handle Notion page event', error: e, event: event.serializable_hash)
      context.fail!(message: e.message, error: e)
      :not_implemented
    ensure
      status = context.success? ? 'succeeded' : 'failed'
      message =
        I18n.t('workflows.handle_notion_page_event_workflow.completed.log',
               event_type: event.type, page: page&.id, status:)
      Rails.logger.info(message, event: event.serializable_hash)
    end

    def database_type
      context.database_type ||= calculate_database_type!
    end

    def klass_type
      context.klass_type ||= calculate_klass_type!
    end

    protected

    def event_type_supported?
      event_type ||= event.type
      supported_event_types = self.class.page_event_class_mapping.values.map(&:keys).flatten.uniq
      unless supported_event_types.include?(event_type)
        unsupported_msg =
          I18n.t(
            'workflows.notion.hangle_page_workflow.errors.unsupported_event_type_v2',
            event_type:, workflow: self.class.name
          )
        context.fail!(message: unsupported_msg)
        return false
      end

      true
    end

    def calculate_database_type!
      # Unknown database ID(s): 25a31362-3069-80ee-8a4a-fbe081d7898c
      @database_type =
        case database&.id
        when webhook.data['deal_database_id']
          :deals
        when webhook.data['vendor_database_id']
          :vendors
        else
          nil
        end
      if @database_type.blank?
        unsupported_msg =
          I18n.t(
            'workflows.notion.hangle_page_workflow.errors.unsupported_db',
            id: database.id, workspace: event.workspace_name, workflow: self.class.name
          )
        raise NotImplementedError, unsupported_msg
      end

      @database_type
    end

    def calculate_klass_type!
      @klass_type = self.class.page_event_class_mapping.dig(database_type, event.type)
      if @klass_type.blank?
        unsupported_msg =
          I18n.t(
            'workflows.notion.hangle_page_workflow.errors.unsupported_event_type_for_db',
            event_type: event.type, database_type:, workspace: event.workspace_name, workflow: self.class.name
          )
        raise NotImplementedError, unsupported_msg
      end

      @klass_type
    end
  end
end
