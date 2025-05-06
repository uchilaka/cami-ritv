# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Class methods
  class << self
    protected

    def server_queue_name
      # Use the server hostname as the queue name to ensure uniqueness across multiple servers.
      @server_queue_name ||= AppUtils.hostname
    end
  end
end
