# frozen_string_literal: true

# @deprecated Use `DDNS::UpsertJob` instead. This class is retained to mitigate
#   potential issues with existing scheduled jobs that reference it, but should not
#   be used for new code.
class DDNSUpsertJob < ApplicationJob
  queue_as :yeet

  def perform(domain: nil, content: nil, type: nil, ttl: 1800)
    Rails.logger.warn "#{self.class} is deprecated. Please use DDNS::UpsertJob instead."

    DDNS::UpsertJob.perform_now(domain:, content:, type:, ttl:)
  end
end
