# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata
#
#  id              :uuid             not null, primary key
#  appendable_type :string
#  key             :string           not null
#  type            :string           default("Metadatum"), not null
#  value           :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  appendable_id   :uuid
#
# Indexes
#
#  index_for_zoho_oauth_serverinfo_metadata  (((value ->> 'region_alpha2'::text)))
#  index_metadata_on_appendable              (appendable_type,appendable_id)
#
module Notion
  class WebhookEventMetadatum < ::Metadatum
    store_accessor :value, %i[
      integration_id
      entity_id
      database_id
      workspace_id
      workspace_name
      remote_record_id
      attempt_number
      entity
      database
    ]

    def self.model_name
      Metadatum.model_name
    end

    def entity_id
      super.presence || (value || {}).dig('entity', 'id')
    end

    alias remote_record_id entity_id

    def database_id
      super.presence || (value || {}).dig('database', 'id')
    end

    def integration_id
      super.presence || (value || {})['integration_id']
    end

    def attempt_number
      super.presence || (value || {})['attempt_number']
    end

    def variant
      (value || {})['type']
    end

    def self.ransackable_attributes(_auth_object = nil)
      super + %w[integration_id entity_id database_id workspace_id workspace_name remote_record_id]
    end

    def self.ransackable_associations(_auth_object = nil)
      super + %w[appendable accounts]
    end

    # def self.ransackable_scopes(_auth_object = nil)
    #   %i[by_integration by_entity by_database by_workspace]
    # end

    # scope :by_integration, ->(integration_id) { where(value: { integration_id: integration_id }) }
    # scope :by_entity, ->(entity_id) { where(value: { entity: { id: entity_id } }) }

    private

    def safe_value
      value || {}
    end
  end
end
