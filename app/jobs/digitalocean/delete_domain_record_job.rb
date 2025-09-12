# frozen_string_literal: true

module DigitalOcean
  class DeleteDomainRecordJob < ApplicationJob
    def perform(id, domain:, access_token: nil, pretend: false)
      DigitalOcean::API.delete_domain_record(id, domain:, access_token:, pretend:)
    end

    private

    def client(access_token: nil)
      @client ||= DigitalOcean::API.http_client(access_token:)
    end
  end
end
