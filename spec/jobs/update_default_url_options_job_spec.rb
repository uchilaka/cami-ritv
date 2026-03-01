# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateDefaultURLOptionsJob, type: :job do
  let(:mock_hostname) { nil }

  around do |example|
    with_modified_env HOSTNAME: mock_hostname, PORT: '1234' do
      example.run
    end
  end

  before do
    # Reset default URL options before each test
    Rails.configuration.action_mailer.default_url_options = {}
    Rails.configuration.action_controller.default_url_options = {}
    AppUtils.instance_variable_set(:@hostname, nil) # Reset cached hostname
  end

  context 'when hostname is not set' do
    let(:mock_hostname) { nil }
    let(:system_hostname) { Socket.gethostname }

    it 'falls back to system hostname' do
      expect do
        described_class.perform_later
        perform_enqueued_jobs
      end.to \
        change { Rails.configuration.action_mailer.default_url_options }
          .to(host: system_hostname, port: '1234').and \
            change { Rails.configuration.action_controller.default_url_options }
              .to(host: system_hostname, port: '1234')
    end
  end

  context 'when hostname is set' do
    context 'and NGINX proxy is not detected' do
      let(:mock_hostname) { 'accounts.larcity.test' }

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

    context 'and NGINX proxy is detected' do
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
end
