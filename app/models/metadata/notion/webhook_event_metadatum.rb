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
    has_one :generic_event, foreign_key: :metadatum_id, dependent: :destroy

    store_accessor :value, %i[integration_id entity_id database_id]

    accepts_nested_attributes_for :generic_event
  end
end
