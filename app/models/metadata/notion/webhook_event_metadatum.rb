# frozen_string_literal: true

module Notion
  class WebhookEventMetadatum < ::Metadatum
    has_one :generic_event, foreign_key: :metadatum_id, dependent: :destroy

    accepts_nested_attributes_for :generic_event
  end
end
