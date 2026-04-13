# frozen_string_literal: true

module Zoho
  class UpdateServerinfoMetadataJob < ApplicationJob
    queue_as :yeet

    def perform(*_args)
      UpdateServerinfoMetadata.call
    end
  end
end
