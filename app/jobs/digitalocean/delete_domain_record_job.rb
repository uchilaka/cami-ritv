# frozen_string_literal: true

module DigitalOcean
  class DeleteDomainRecordJob < ApplicationJob
    def perform(domain:, name:, type:)
    end

    private

    def client
      @client ||= DigitalOcean::API.http_client
    end
  end
end
