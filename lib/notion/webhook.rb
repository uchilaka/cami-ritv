# frozen_string_literal: true

require 'singleton'

module Notion
  class Webhook
    include Singleton

    attr_reader :record, :slug, :verification_token

    delegate :slug,
             :integration_id,
             :integration_name,
             :verification_token, to: :record

    def initialize
      @record = ::Webhook.find_by(slug: 'notion')
    end
  end
end
