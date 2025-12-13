# frozen_string_literal: true

module LogUtils
  class << self
    def streaming_enabled?
      AppUtils.yes? ENV.fetch('SEMANTIC_LOGGER_STREAMING_ENABLED', 'yes')
    end

    def streaming_via_http?
      SemanticLogger.appenders.any? { |a| a.is_a?(SemanticLogger::Appender::Http) }
    end

    def log_stream_token!
      @log_stream_token = ENV.fetch('BETTERSTACK_SOURCE_TOKEN', nil)
      @log_stream_token ||= Rails.application.credentials.betterstack.source_token!
    end

    def log_stream_ingestion_host!
      @log_stream_ingestion_host = ENV.fetch('BETTERSTACK_INGESTION_HOST', 'in.logs.betterstack.com')
      @log_stream_ingestion_host ||= Rails.application.credentials.betterstack.ingestion_host!
    end

    def initialize_stream
      # Stdout appender
      SemanticLogger.add_appender(io: $stdout, level: :debug, formatter: :color)
      if streaming_enabled?
        # BetterStack via HTTPS Appender
        SemanticLogger.add_appender(
          appender: SemanticLogger::Appender::Http.new(
            url: "https://#{log_stream_ingestion_host!}",
            ssl: { verify: OpenSSL::SSL::VERIFY_NONE },
            header: {
              'Content-Type': 'application/json',
              Authorization: "Bearer #{log_stream_token!}",
            }
          )
        )
      end
    end

    def verbose_query_logs?
      log_output_level(log_level) > log_output_level(:info)
    end

    def log_level
      Rails.application.config.log_level || :info
    end

    # Log output level where :error is the lowest (1)
    # and :debug is the highest (4)
    def log_output_level(log_level)
      case log_level.to_s
      when 'debug'
        4
      when 'info'
        3
      when 'warn'
        2
      when 'error'
        1
      else
        3
      end
    end

    protected

    def log_path
      log_path = Rails.root.join('log', Time.now.strftime('%Y-%m-%d')).to_s
      FileUtils.mkdir_p(log_path)
      log_path
    end

    def log_file(ext: 'log')
      "#{log_path}/#{Rails.env}.#{ext}"
    end
  end
end
