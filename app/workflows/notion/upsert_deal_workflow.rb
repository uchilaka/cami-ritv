# frozen_string_literal: true

module Notion
  class UpsertDealWorkflow
    include Interactor

    def call
      context.entity = context.event.entity
      context.database = context.event.parent
      context.remote_record_id = context.entity.id

      # # Assuming you have a method to upsert the entity in Notion
      # result = Notion::EntityService.upsert(notion_entity)
      #
      # if result.success?
      #   context.notion_entity = result.entity
      # else
      #   context.fail!(error: result.error)
      # end
    ensure
      event_id = context.event.id
      status = context.success? ? 'success' : 'failure'
      log_message =
        I18n.t('workflows.upsert_deal_workflow.completed.log', status:, slug: 'fake-deal-slug')
      Rails.logger.info(log_message, event_id:)
    end
  end
end
