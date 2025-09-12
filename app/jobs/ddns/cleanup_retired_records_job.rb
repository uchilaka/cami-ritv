# frozen_string_literal: true

require 'lib/commands/lar_city/cli/ddns_cmd'

module DDNS
  class CleanupRetiredRecordsJob < ApplicationJob
    def perform
      Rails.application.config_for('ddns/retired').each do |record|
        domain, record, record_type =
          record.values_at(:domain, :content, :type)
        raise ArgumentError, 'Domain is required' if domain.blank?
        raise ArgumentError, 'Domain record content is required' if record.blank?
        raise ArgumentError, 'Domain record type is required' if record_type.blank?

        Rails.logger.info('Checking retired DDNS record', domain:, record:, record_type:)
        LarCity::CLI::DDNSCmd
          .new
          .invoke(
            :cleanup, [],
            domain:, record:, type: record_type, verbose: Rails.env.development?, dry_run: true
          )
      end
    end
  end
end
