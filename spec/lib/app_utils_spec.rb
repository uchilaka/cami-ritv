# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppUtils, utility: true, skip_in_ci: true do
  describe '.healthy?' do
    context 'when the resource is healthy' do
      let(:stubs) { Faraday::Adapter::Test::Stubs.new }
      let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }

      before do
        allow(Faraday).to receive(:get) { |url| conn.get(url) }
      end

      after do
        allow(Faraday).to receive(:get).and_call_original
      end

      it 'returns true' do
        stubs.get(%r{/healthz}) { [200, {}, 'OK'] }
        expect(described_class.healthy?('https://accounts.larcity.test/healthz')).to eq(true)
      end
    end

    context 'when the resource is not healthy' do
      let(:stubs) { Faraday::Adapter::Test::Stubs.new }
      let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }

      before do
        allow(Faraday).to receive(:get) { |url| conn.get(url) }
      end

      after do
        allow(Faraday).to receive(:get).and_call_original
      end

      it 'returns false' do
        stubs.get(%r{/healthz}) { [500, {}, 'Internal Server Error'] }
        expect(described_class.healthy?('https://accounts.larcity.test/healthz')).to eq(false)
      end
    end

    context 'when the resource is unavailable' do
      let(:stubs) { Faraday::Adapter::Test::Stubs.new }
      let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }

      before do
        allow(Faraday).to receive(:get) { |url| conn.get(url) }
      end

      after do
        allow(Faraday).to receive(:get).and_call_original
      end

      it 'returns false' do
        stubs.get(%r{/healthz}) { raise Faraday::ConnectionFailed, 'Connection failed' }
        expect(described_class.healthy?('https://accounts.larcity.test/healthz')).to eq(false)
      end
    end
  end

  describe '.ping?' do
    let(:hostname) { 'example.com' }

    subject { described_class.ping?(hostname) }

    context 'when the host is reachable' do
      let(:hostname) { 'wikipedia.org' }

      it { expect(subject).to eq true }
    end

    context 'when the host is not reachable' do
      let(:hostname) { 'notarealhost' }

      it { expect(subject).to eq false }
    end
  end

  describe '.yes?' do
    it 'returns true if value is true' do
      expect(described_class.yes?(true)).to eq(true)
    end

    it 'returns true if value is 1' do
      expect(described_class.yes?(1)).to eq(true)
    end

    it 'returns false if value is nil' do
      expect(described_class.yes?(nil)).to eq(false)
    end

    it 'returns true if value is "yes"' do
      expect(described_class.yes?('yes')).to eq(true)
    end

    it 'returns true if value is "true"' do
      expect(described_class.yes?('true')).to eq(true)
    end

    it 'returns true if value is "on"' do
      expect(described_class.yes?('on')).to eq(true)
    end

    it 'returns false if value is "no"' do
      expect(described_class.yes?('no')).to eq(false)
    end
  end

  describe '.configure_real_smtp?' do
    let(:letter_opener_enabled) { nil }
    let(:mailhog_enabled) { nil }
    let(:send_live_emails_enabled) { nil }

    around do |example|
      with_modified_env(
        SEND_EMAILS_ENABLED: send_live_emails_enabled,
        LETTER_OPENER_ENABLED: letter_opener_enabled,
        MAILHOG_ENABLED: mailhog_enabled
      ) do
        example.run
      end
    end

    context 'when letter_opener is enabled and mailhog is disabled' do
      let(:letter_opener_enabled) { 'yes' }
      let(:mailhog_enabled) { 'no' }

      it 'returns false' do
        expect(described_class.configure_real_smtp?).to eq(false)
      end
    end

    context 'when letter_opener is disabled and mailhog is enabled' do
      let(:letter_opener_enabled) { 'no' }
      let(:mailhog_enabled) { 'yes' }

      it 'returns false' do
        expect(described_class.configure_real_smtp?).to eq(false)
      end
    end

    context 'when letter_opener is disabled and mailhog is disabled' do
      let(:letter_opener_enabled) { 'no' }
      let(:mailhog_enabled) { 'no' }

      it 'returns false' do
        expect(described_class.configure_real_smtp?).to eq(false)
      end

      context 'when the application is in production' do
        before do
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        after do
          allow(Rails.env).to receive(:production?).and_call_original
        end

        it 'returns true' do
          expect(described_class.configure_real_smtp?).to eq(true)
        end
      end

      context 'when SEND_EMAILS_ENABLED is true' do
        let(:send_live_emails_enabled) { 'yes' }

        it 'returns true' do
          expect(described_class.configure_real_smtp?).to eq(true)
        end
      end
    end

    context 'when letter_opener is enabled and mailhog is enabled' do
      let(:letter_opener_enabled) { 'yes' }
      let(:mailhog_enabled) { 'yes' }

      it 'returns false' do
        expect(described_class.configure_real_smtp?).to eq(false)
      end
    end
  end

  describe '.letter_opener_enabled?' do
    let(:letter_opener_enabled) { nil }

    around do |example|
      with_modified_env(LETTER_OPENER_ENABLED: letter_opener_enabled) do
        example.run
      end
    end

    context 'when LETTER_OPENER_ENABLED is nil' do
      it 'returns true' do
        expect(described_class.letter_opener_enabled?).to eq(true)
      end
    end

    context 'when LETTER_OPENER_ENABLED is "yes"' do
      let(:letter_opener_enabled) { 'yes' }

      it 'returns false' do
        expect(described_class.letter_opener_enabled?).to eq(true)
      end
    end

    context 'when LETTER_OPENER_ENABLED is "no"' do
      let(:letter_opener_enabled) { 'no' }

      it 'returns true' do
        expect(described_class.letter_opener_enabled?).to eq(false)
      end
    end
  end

  describe '.send_emails?' do
    context 'when SEND_EMAILS_ENABLED is nil' do
      around do |example|
        with_modified_env(SEND_EMAILS_ENABLED: nil) do
          example.run
        end
      end

      context 'and the application is in production' do
        before do
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        after do
          allow(Rails.env).to receive(:production?).and_call_original
        end

        it 'returns true' do
          expect(described_class.send_emails?).to eq(true)
        end
      end

      context 'and letter_opener (otherwise ENV defaults)' do
        let(:letter_opener_enabled) { nil }

        around do |example|
          with_modified_env(
            MAILHOG_ENABLED: 'no',
            LETTER_OPENER_ENABLED: letter_opener_enabled
          ) do
            example.run
          end
        end

        context 'is enabled' do
          let(:letter_opener_enabled) { 'yes' }

          it 'returns true' do
            expect(described_class.send_emails?).to eq(true)
          end
        end

        context 'is disabled' do
          let(:letter_opener_enabled) { 'no' }

          it 'returns false' do
            expect(described_class.send_emails?).to eq(false)
          end
        end
      end

      context 'and mailhog' do
        let(:mailhog_enabled) { nil }

        around do |example|
          with_modified_env(
            MAILHOG_ENABLED: mailhog_enabled
          ) do
            example.run
          end
        end

        context 'is disabled' do
          let(:mailhog_enabled) { 'no' }

          it 'returns true' do
            expect(described_class.send_emails?).to eq(true)
          end
        end

        context 'is enabled' do
          let(:mailhog_enabled) { 'yes' }

          it 'returns true' do
            expect(described_class.send_emails?).to eq(true)
          end
        end
      end
    end
  end

  # TODO: Is this still passing?
  describe '.live_reload_enabled?' do
    context 'when the OS is Windows' do
      before do
        allow(AppUtils).to receive(:friendly_os_name).and_return(:windows)
      end

      it 'returns false' do
        expect(described_class.live_reload_enabled?).to eq(false)
      end
    end

    context 'when the OS is not Windows' do
      before do
        allow(AppUtils).to receive(:friendly_os_name).and_return(:unsupported)
      end

      context 'and Rails.env.development? is true' do
        let(:mock_env) { 'development' }
        let(:mock_env_var) { nil }

        before do
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        after do
          allow(Rails.env).to receive(:development?).and_call_original
        end

        around do |example|
          with_modified_env(RAILS_LIVE_RELOAD_ENABLED: mock_env_var) do
            example.run
          end
        end

        context 'and the OS is Linux' do
          before do
            allow(AppUtils).to receive(:friendly_os_name).and_return(:linux)
          end

          it { expect(described_class.live_reload_enabled?).to be(false) }
        end

        context 'and the OS is macOS' do
          before do
            allow(AppUtils).to receive(:friendly_os_name).and_return(:macos)
          end

          context "and ENV['RAILS_LIVE_RELOAD_ENABLED'] is truthy" do
            let(:mock_env_var) { 'yes' }

            it { expect(described_class.live_reload_enabled?).to be(true) }
          end

          context "and ENV['RAILS_LIVE_RELOAD_ENABLED'] is falsy" do
            let(:mock_env_var) { 'no' }

            it { expect(described_class.live_reload_enabled?).to be(false) }
          end
        end

      end

      context 'and Rails.env.development? is false' do
        it { expect(described_class.live_reload_enabled?).to eq(false) }
      end
    end
  end
end
