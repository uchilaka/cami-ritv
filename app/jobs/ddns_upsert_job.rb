# frozen_string_literal: true

class DDNSUpsertJob < ApplicationJob
  queue_as :yeet

  def perform(domain: nil, content: nil, type: nil, ttl: 1800)
    if domain.nil?
      records.each_with_index do |record, index|
        domain, content, type, ttl = record.values_at(:domain, :content, :type, :ttl)
        self.class.set(wait: ((index + 1) * 15).seconds).perform_later(domain:, content:, type:, ttl:)
      end
    else
      ::LarCity::CLI::DDNSCmd.new.invoke(:upsert, [], domain:, record: content, type:, ttl:)
    end
  end

  private

  def records
    Rails.application.config_for('ddns/active') || []
  end
end
