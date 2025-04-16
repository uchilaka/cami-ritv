# frozen_string_literal: true

Rails.configuration.before_initialize do |app|
  # NOTE: Initialize the log stream unless we are running tests
  #   or streaming is already initialized
  LogUtils.initialize_stream unless Rails.env.test? || LogUtils.streaming_via_http?
  # Configure logging for dependent services
  app.config.action_mailer.logger = Rails.logger
  # Configure the log level for the active record logger
  ActiveRecord::Base.logger.level =
    if AppUtils.yes?(ENV.fetch('ENV_VERBOSE_QUERY_LOGS', 'no'))
      Logger::DEBUG
    else
      Rails.logger.level
    end
end
