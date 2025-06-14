# frozen_string_literal: true

module Notion
  class UpsertDealWorkflow
    include Interactor

    def call
      context.entity = context.event.entity
      context.database = context.event.parent
      context.remote_record_id = context.entity.id

      case context.event.type
      when 'page.created'
        context.system_event = ::Notion::DealCreatedEvent.new(
          metadatum: {
            remote_record_id: context.remote_record_id,
            database: context.database.serializable_hash,
            **context.event.serializable_hash,
          }
        )
      when 'page.properties_updated'
        context.system_event = ::Notion::DealUpdatedEvent.new(
          metadatum: {
            remote_record_id: context.remote_record_id,
            database: context.database.serializable_hash,
            **context.event.serializable_hash,
          }
        )
      else
        error =
          I18n.t('workflows.upsert_deal_workflow.errors.unsupported_event_type', event_type: context.event.type)
        fail!(error:)
      end
    ensure
      remote_event_id = context.event.id
      status = context.success? ? 'success' : 'failure'
      log_message =
        I18n.t('workflows.upsert_deal_workflow.completed.log', status:, slug: 'fake-deal-slug')
      Rails.logger.info(log_message, remote_event_id:, system_event: context.system_event&.serializable_hash)
    end
  end
end
