# frozen_string_literal: true

require 'fileutils'

# See https://stackoverflow.com/a/837593/3726759
$LOAD_PATH.unshift(File.join(Dir.pwd, 'app'))

require 'concerns/operating_system_detectable'

class AppUtils
  include OperatingSystemDetectable

  module DeviseJWT
    class RequestRegex
      SIGN_IN = %r{^/users/sign_in$}
      SIGN_OUT = %r{^/users/sign_out$}
      # Test: https://rubular.com/r/7bDMX2Vmr1O8AP
      OMNIAUTH_CALLBACK = %r{^/users/auth/([\w\-_])+/callback$}
    end
  end

  class << self
    def crm_org_id
      override_value = ENV.fetch('CRM_ORG_ID', nil)
      return override_value if override_value.present?

      Rails.application.credentials.crm&.org_id!
    end

    def configure_real_smtp?
      send_emails? && !letter_opener_enabled? && !mailhog_enabled?
    end

    def hostname_is_nginx_proxy?
      /\.ngrok\.(dev|app)/.match?(hostname)
    end

    def use_secure_protocol?
      Rails.env.production? || hostname_is_nginx_proxy?
    end

    # LetterOpener should be enabled by default in the development environment
    def letter_opener_enabled?
      configured_value = Rails.application.credentials.letter_opener_enabled
      return configured_value unless configured_value.nil?

      yes?(ENV.fetch('LETTER_OPENER_ENABLED', 'yes'))
    end

    def mailhog_enabled?
      configured_value = Rails.application.credentials.mailhog_enabled
      return configured_value unless configured_value.nil?

      yes?(ENV.fetch('MAILHOG_ENABLED', 'no'))
    end

    def send_emails?
      default_value =
        Rails.env.production? || mailhog_enabled? || letter_opener_enabled?

      yes?(ENV.fetch('SEND_EMAILS_ENABLED', default_value))
    end

    def yes?(value)
      return true if [true, 1].include?(value)
      return false if value.nil?

      /^Y(es)?|^T(rue)|^On$/i.match?(value.to_s.strip)
    end

    def ping?(host)
      result = system("ping -c 1 -W 1 #{host}", out: '/dev/null', err: '/dev/null')
      result.nil? ? false : result
    end

    def healthy?(resource_url)
      response = Faraday.get(resource_url) do |options|
        options.headers = {
          'User-Agent' => 'VirtualOfficeManager health check bot v1.0'
        }
      end
      Rails.logger.info "Health check for #{resource_url}", response: response.inspect
      response.success?
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Health check for #{resource_url} failed", error: e.message
      false
    end

    def debug_mode?
      default_value = Rails.env.production? ? 'no' : 'yes'

      yes?(ENV.fetch('APP_DEBUG_MODE', default_value))
    end

    # @deprecated Refactor as alias for debug_mode?
    def debug_assets?
      default_value = Rails.env.development? ? 'yes' : 'no'

      yes?(ENV.fetch('ENV_DEBUG_ASSETS', default_value))
    end

    def hostname
      # TODO: Check if tunnel is available and use the NGROK hostname if so
      #   otherwise, fallback to the configured hostname 👇🏾
      ENV.fetch('HOSTNAME', Rails.application.credentials.hostname)
    end

    def log_level
      if yes?(ENV.fetch('LOG_LEVEL_DEBUG', 'no'))
        :debug
      else
        :info
      end
    end

    def log_file
      @log_file ||= ENV.fetch('LOG_FILE', nil)
      @log_file || Rails.root.join("log/#{ENV.fetch('RAILS_ENV', 'cami')}.log").to_s
    end

    def allowed_hosts_for(provider:)
      Rails
        .application
        .config_for(:allowed_3rd_party_hosts)[provider.to_sym] || {}
    end

    def ruby_version(file_path = nil)
      file_path ||= "#{Dir.pwd}/.tool-versions"
      raise 'Error: .tool-versions file not found' unless File.exist?(file_path)

      File.foreach(file_path) do |line|
        match = line.match(/ruby\s+([\d.]+)/)
        return match[1].to_s.strip if match
      end

      raise 'No ruby version found in .tool-versions'
    end

    # TODO: is this deprecated or refactored as implemented elsewhere?
    def live_reload_enabled?
      case friendly_os_name
      when :windows, :linux
        false
      else
        Rails.env.development? &&
          yes?(ENV.fetch('RAILS_LIVE_RELOAD_ENABLED', 'yes'))
      end
    end

    def jbuilder_pre_keys
      @jbuilder_pre_keys ||= begin
        keys = Rails.application.credentials&.jbuilder&.pre_keys || %i[predicate]
        keys.is_a?(Array) ? keys : [keys]
      end
    end
  end
end
