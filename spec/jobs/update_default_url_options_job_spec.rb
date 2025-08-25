# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateDefaultURLOptionsJob, type: :job do
  let(:mock_hostname) { 'accounts.larcity.test' }

  around do |example|
    with_modified_env HOSTNAME: mock_hostname, PORT: '1234' do
      example.run
    end
  end

  context 'when NGINX proxy is not detected' do
    it 'updates the default URL options' do
      expect do
        described_class.perform_later
        perform_enqueued_jobs
      end.to \
        change { Rails.configuration.action_mailer.default_url_options }
          .to(host: mock_hostname, port: '1234').and \
            change { Rails.configuration.action_controller.default_url_options }
              .to(host: mock_hostname, port: '1234')
    end
  end

  context 'when NGINX proxy is detected' do
    let(:mock_hostname) { 'accounts.larcity.ngrok.app' }

    it 'updates the default URL options' do
      expect do
        described_class.perform_later
        perform_enqueued_jobs
      end.to \
        change { Rails.configuration.action_mailer.default_url_options }
          .to(host: mock_hostname).and \
            change { Rails.configuration.action_controller.default_url_options }
              .to(host: mock_hostname)
    end
  end
end
