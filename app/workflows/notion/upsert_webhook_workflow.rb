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
    delegate :dataset, :webhook, :message, to: :context

    def call
      require_dataset_support_if_set!

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
      workflow_actions = actions_map[dataset]
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

      context.webhook = Webhook.find_or_initialize_by(dataset:, slug:, verification_token:)

      Webhook.transaction do
        if webhook.persisted?
          Rails.logger.info('⏳️ Updating webhook', slug: webhook.slug)
        else
          Rails.logger.info('⏳️ Setting up webhook', vendor:, slug: webhook.slug)
        end

        @new_record = webhook.new_record?

        if new_record? || force?
          webhook.data = upserts.compact
        else
          webhook.set_on_data(**upserts.compact)
        end

        if webhook.changed?
          webhook.save!
          context.message =
            if new_record?
              '🚀 Webhook has been created successfully.'
            else
              '⚡ Webhook has been updated successfully.'
            end
          Rails.logger.info(message, vendor:, dataset:)
        else
          context.message = '💅🏾 Webhook is already up to date.'
          Rails.logger.info(message, vendor:, dataset:)
        end
      end
    ensure
      if webhook&.persisted? && webhook.errors.none?
        Rails.logger.info("✅ #{self.class.name} succeeded", vendor:, dataset:)
        return
      end

      # Since there's no persisted webhook, this should be treated as a failure.
      context.message = "❌ #{self.class.name} failed"
      context.fail!(message:) if context.success?
      Rails.logger.error(message, vendor:, dataset:, errors: webhook&.errors&.full_messages)
    end

    protected

    def require_dataset_support_if_set!
      return if dataset.blank?

      unless supported_datasets.include?(dataset.to_s)
        error =
          StandardError.new(
            I18n.t('workflows.notion.upsert_webhook_workflow.errors.unsupported_dataset', dataset:)
          )
        context.fail!(error:)
        raise error
      end
    end

    def new_record?
      @new_record
    end

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
      # If no supported dataset is provided, default to deal_database_id for backward compatibility.
      return :deal_database_id if supported_dataset.blank?

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
          # Return a hash that defaults to deal_actions_map for any unsupported dataset.
          # This ensures that even if a dataset is not explicitly defined, it will still
          # have the deal actions available for backward compatibility.
          register = Hash.new(deal_actions_map)
          register
            .merge(
              deal: deal_actions_map,
              # Ensure vendor dataset actions are defined when supported in the future
              vendor: {}
            )
            .with_indifferent_access
        end
    end

    def deal_actions_map
      {
        records_index_workflow_name: Notion::Deals::DownloadLatestWorkflow.name,
        record_download_workflow_name: Notion::Deals::DownloadWorkflow.name,
      }
    end
  end
end
