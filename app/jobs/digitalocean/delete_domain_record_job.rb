# frozen_string_literal: true

module DigitalOcean
  class DeleteDomainRecordJob < ApplicationJob
    def perform(domain:, name:, type:)
    end

    private

    def client
      @client ||=
        begin

        end
    end
  end
end
