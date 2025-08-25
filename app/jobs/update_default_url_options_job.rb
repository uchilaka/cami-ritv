# frozen_string_literal: true

class UpdateDefaultURLOptionsJob < ApplicationJob
  # Configure ActiveJob retry behavior
  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  # Use a lower priority queue for this job
  queue_as :yeet

  attr_reader :routing_context

  def initialize(*)
    super
    @routing_context ||= :app
  end

  def perform(*_args)
    update_mailer_default_url_options
    update_controller_default_url_options
  end

  private

  def update_mailer_default_url_options
    log_baselines
    @routing_context = :mailer
    # Set the default_url_options for mailers
    Rails.configuration.action_mailer.default_url_options = VirtualOfficeManager.default_url_options
    # Check if the default_url_options have been updated
    Rails.logger.info("#{self.class.name} COMPARE: ActionMailer default_url_options", default_url_options:)
    # Check application-wide default_url_options
    Rails.logger.info(
      "#{self.class.name} COMPARE: Application default_url_options",
      default_url_options: Rails.application.default_url_options
    )
  end

  def update_controller_default_url_options
    log_baselines
    @routing_context = :controller
    # Set the default_url_options for mailers
    Rails.configuration.action_controller.default_url_options = VirtualOfficeManager.default_url_options
    # Check if the default_url_options have been updated
    Rails.logger.info("#{self.class.name} COMPARE: ActionController default_url_options", default_url_options:)
    # Check application-wide default_url_options
    Rails.logger.info(
      "#{self.class.name} COMPARE: Application default_url_options",
      default_url_options: Rails.application.default_url_options
    )
  end

  def log_baselines
    # Log the baseline for the default_url_options for ActionMailer
    Rails.logger.info("#{self.class.name} BASELINE: ActionController default_url_options", default_url_options:)
    @routing_context = :mailer
    # Log the baseline for the application-wide default_url_options
    Rails.logger.info("#{self.class.name} COMPARE: Application default_url_options", default_url_options:)
    # Set the routing context back to the app (default)
    @routing_context = :app
  end

  def default_url_options
    case routing_context
    when :mailer
      Rails.configuration.action_mailer.default_url_options
    else
      Rails.configuration.action_controller.default_url_options
    end
  end
end
