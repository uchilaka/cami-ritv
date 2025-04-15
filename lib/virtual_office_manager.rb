# frozen_string_literal: true

# require 'sidekiq/api'

# This class is intended to facilitate access to business related
#   defaults and information with support for retrieving
#   data from secure or encrypted sources.
class VirtualOfficeManager
  class << self
    delegate :hostname,
             :use_secure_protocol?,
             :hostname_is_nginx_proxy?, to: AppUtils

    # # @deprecated use AppUtils.hostname instead
    # def hostname
    #   # TODO: Check if tunnel is available and use the NGROK hostname if so
    #   #   otherwise, fallback to the configured hostname 👇🏾
    #   ENV.fetch('HOSTNAME', Rails.application.credentials.hostname)
    # end
    #
    # # @deprecated use AppUtils.hostname_is_nginx_proxy? instead
    # def hostname_is_nginx_proxy?
    #   /\.ngrok\.(dev|app)/.match?(hostname)
    # end

    # def job_queue_is_running?
    #   scheduled_set = Sidekiq::ScheduledSet.new
    #   job_stats = Sidekiq::Stats.new
    #   scheduled_set.size.positive? || job_stats.enqueued.positive?
    # end

    def default_url_options
      # Only run this in the context of a job
      if !defined?(Rails::Server) && Flipper.enabled?(:feat__hostname_health_check)
        # TODO: Dynamically determine whether HTTPS or HTTP should be used for this check
        protocol = use_secure_protocol? ? 'https' : 'http'
        health_endpoint = "#{protocol}://#{hostname}/up"
        return { host: hostname } if AppUtils.healthy?(health_endpoint)
      end

      initial_default_url_options
    end

    def initial_default_url_options
      { host: hostname, port: hostname_is_nginx_proxy? ? nil : ENV.fetch('PORT') }.compact
    end

    def default_entity
      entities&.larcity
    end

    def entities
      Rails.application.credentials.entities
    end

    def entity_by_key(entity_key)
      return nil if entity_key.blank?

      entities&.send(entity_key)
    end

    def logstream_vendor_url
      return nil if logstream_vendor&.team_id.blank? || logstream_vendor&.source_id.blank?

      [
        'https://logs.betterstack.com/team/',
        logstream_vendor.team_id,
        '/tail?s=',
        logstream_vendor.source_id
      ].join
    end

    def logstream_vendor
      Rails.application.credentials.betterstack
    end

    def web_console_permissions
      return nil if Rails.env.test?

      ENV.fetch('LAN_SUBNET_MASK', Rails.application.credentials.web_console.permissions)
    end
  end
end
