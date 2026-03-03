# frozen_string_literal: true

require 'lib/commands/lar_city/cli/ddns_cmd'

module DDNS
  class PruneDuplicateRecordsJob < ApplicationJob
    queue_as :high

    def perform
      Rails.application.config_for('ddns/dirty').each do |record|
        domain, record, record_type =
          record.values_at(:domain, :content, :type)
        raise ArgumentError, 'Domain is required' if domain.blank?
        raise ArgumentError, 'Domain record content is required' if record.blank?
        raise ArgumentError, 'Domain record type is required' if record_type.blank?

        Rails.logger.info('Checking for duplicate DDNS record', domain:, record:, record_type:)
        LarCity::CLI::DDNSCmd
          .new
          .invoke(
            :prune,
            [], batch_size: 100,
            domain:, record:, type: record_type, verbose: Rails.env.development?
          )
      end
    end
  end
end
