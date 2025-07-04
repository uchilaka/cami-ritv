# frozen_string_literal: true

require 'rails_helper'
require 'commands/lar_city/cli/base_cmd'

load_lib_script 'commands', 'features_cmd', ext: 'thor'

RSpec.describe FeaturesCmd do
  describe '#init' do
    let(:features_config) do
      {
        feature_one: { enabled: true },
        feature_two: { enabled: false },
      }
    end

    before do
      allow(Rails.application).to receive(:config_for).with(:features).and_return(features_config)
      allow(Flipper).to receive(:exist?).and_return(false)
      allow(Flipper).to receive(:add)
      allow(Flipper).to receive(:enable)
      allow(Flipper).to receive(:disable)
    end

    it 'initializes feature flags from the configuration' do
      expect(Flipper).to receive(:add).with(:feature_one)
      expect(Flipper).to receive(:enable).with(:feature_one)
      expect(Flipper).to receive(:add).with(:feature_two)
      expect(Flipper).to receive(:disable).with(:feature_two)

      described_class.start(['init'])
    end

    it 'skips existing feature flags' do
      allow(Flipper).to receive(:exist?).with(:feature_one).and_return(true)

      expect(Flipper).not_to receive(:add).with(:feature_one)
      expect(Flipper).not_to receive(:enable).with(:feature_one)
      expect(Flipper).to receive(:add).with(:feature_two)
      expect(Flipper).to receive(:disable).with(:feature_two)

      described_class.start(['init'])
    end
  end
end