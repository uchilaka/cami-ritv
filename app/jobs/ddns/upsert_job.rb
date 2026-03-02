# frozen_string_literal: true

module DDNS
  class UpsertJob < ApplicationJob
    class << self
      def upsert_domains!
        Domain::Name.transaction do
          domains.each do |hostname|
            Domain::Name.find_or_create_by!(hostname:, status: 'active')
          end
        end
      end

      def records
        Rails.application.config_for('ddns/active').map do |record|
          Struct::DnsRecordConfig
            .new(**record.symbolize_keys.slice(:domain, :content, :type, :ttl))
        end || []
      end

      private

      def domains
        @domains ||= records.map(&:domain).uniq
      end
    end

    queue_as :high

    def perform(domain: nil, content: nil, type: nil, ttl: 1800)
      if domain.nil?
        # Make sure all configured domains exist before upserting records, otherwise the CLI command will fail
        self.class.upsert_domains!
        # Stagger the upsert operations to avoid hitting rate limits or overwhelming the system
        self.class.records.each_with_index do |record, index|
          domain, content, type, ttl = record.to_h.values_at(:domain, :content, :type, :ttl)
          self.class.set(wait: ordered_delay_in_seconds(index)).perform_later(domain:, content:, type:, ttl:)
        end
      else
        ::LarCity::CLI::DDNSCmd.new.invoke(:upsert, [], domain:, record: content, type:, ttl:)
      end
    end

    protected

    def ordered_delay_in_seconds(index = 0)
      ((index + 1) * 15).seconds
    end
  end
end
