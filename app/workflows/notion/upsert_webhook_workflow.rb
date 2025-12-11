# frozen_string_literal: true

module Notion
  # A dataset-specific webhook can utilize the same vendor credentials but will need separate
  # instances to manage different datasets/databases vendor (e.g., deals, vendors).
  #
  # If dataset is unset for a webhook record, it is assumed to be a generic webhook for the vendor.
  class UpsertWebhookWorkflow
    include Interactor

    delegate :integration_id,
             :verification_token,
             :database_id,
             to: :credentials
    delegate :dataset, to: :context

    def call
      raise I18n.t('workflows.notion.upsert_webhook_workflow.errors.missing_dataset') if dataset.blank?

      unless supported_datasets.include?(dataset.to_s)
        raise I18n.t('workflows.notion.upsert_webhook_workflow.errors.unsupported_dataset', dataset:)
      end

      integration_id, verification_token =
        Rails.application.credentials.notion&.values_at :integration_id, :verification_token
      database_id = credentials.send(:"#{database_id_key}!")
      if integration_id.blank?
        raise I18n.t('workflows.notion.upsert_webhook_workflow.errors.missing_integration', dataset:)
      end
      if verification_token.blank?
        raise I18n.t('workflows.notion.upsert_webhook_workflow.errors.missing_verification_token', dataset:)
      end

      dashboard_url = "https://www.notion.so/profile/integrations/internal/#{integration_id}"
      workflow_actions = actions_map[dataset.to_sym]
      upserts = {
        integration_id:,
        database_id:,
        database_id_key => database_id,
        dashboard_url:,
        **workflow_actions,
      }.compact

      actions_map.each_key do |supported_dataset|
        config_key = database_id_key(supported_dataset).to_sym
        upserts[config_key] = credentials.send(config_key)
      end

      ::Webhook.transaction do
        webhook = ::Webhook.find_or_initialize_by(dataset:, slug:, verification_token:)

        if webhook.persisted?
          Rails.logger.info('⏳️ Updating webhook', slug: webhook.slug)
        else
          Rails.logger.info('⏳️ Setting up webhook', vendor:, slug: webhook.slug)
        end

        if webhook.new_record? || force?
          webhook.data = upserts.compact!
          if webhook.changed?
            webhook.save!
            Rails.logger.info('⚡ Webhook has been set up successfully.', vendor:, dataset:)
          else
            Rails.logger.info('💅🏾 Webhook is already set up and no changes were made.', vendor:, dataset:)
          end
        else
          webhook.set_on_data(**upserts)
          if webhook.changed?
            webhook.save!
            Rails.logger.info('⚡ Webhook has been updated successfully.', vendor:, dataset:)
          else
            Rails.logger.info('💅🏾 Webhook is already up to date.', vendor:, dataset:)
          end
        end
      end
    end

    protected

    def force?
      context.force || false
    end

    def slug
      [vendor.to_s, dataset.to_s.pluralize].compact.join('-').to_sym
    end

    def vendor
      :notion
    end

    def database_id_key(supported_dataset = dataset)
      :"#{supported_dataset}_database_id"
    end

    def supported_datasets
      %w[deal vendor]
    end

    def credentials
      Rails.application.credentials.notion
    end

    def actions_map
      @actions_map ||=
        begin
          register = Hash.new({})
          register
            .merge(
              deal: {
                records_index_workflow_name: Notion::Deals::DownloadLatestWorkflow.name,
                records_download_workflow_name: Notion::Deals::DownloadWorkflow.name,
              },
              vendor: {}
            )
        end
    end
  end
end
