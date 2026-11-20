# frozen_string_literal: true

require 'rails_helper'
require 'lar_city/cli/service_helpers'

RSpec.describe LarCity::CLI::ServiceHelpers::ClassMethods do
  # A bare class rather than ServicesCmd or ImagesCmd: these are class methods with
  # class-level memoisation, so exercising a real command would leave its memo poisoned
  # for every other example in the run.
  subject(:host) { Class.new { extend LarCity::CLI::ServiceHelpers::ClassMethods } }

  # Stub only the candidate paths. A blanket `allow(File).to receive(:exist?)` would also
  # intercept Rails' own lookups for the remainder of the example.
  def stub_files(present: [], missing: [])
    allow(File).to receive(:exist?).and_call_original
    { true => present, false => missing }.each do |result, basenames|
      basenames.each do |basename|
        allow(File).to receive(:exist?).with(Rails.root.join(basename).to_s).and_return(result)
      end
    end
  end

  describe '.compose_config_file' do
    it 'prefers a candidate that exists over the fallback' do
      stub_files(missing: %w[compose.yml], present: %w[docker-compose.yml])

      expect(host.compose_config_file).to eq(Rails.root.join('docker-compose.yml').to_s)
    end

    # The regression. The fallback used to live in an `ensure` block, which runs for its
    # side effects but does NOT set the method's return value. The memo was assigned, so
    # the SECOND call was correct while the FIRST returned nil -- and callers went on to
    # File.exist?(nil), which raises TypeError.
    context 'when no candidate exists' do
      before { stub_files(missing: %w[compose.yml docker-compose.yml]) }

      it 'falls back on the first call, not only on later ones' do
        expect(host.compose_config_file).to eq(Rails.root.join('compose.yml').to_s)
      end

      it 'returns the same value on the first and second call' do
        expect(host.compose_config_file).to eq(host.compose_config_file)
      end
    end
  end

  describe '.compose_override_config_file' do
    it 'prefers a candidate that exists over the fallback' do
      stub_files(missing: %w[compose.override.yml], present: %w[docker-compose.override.yml])

      expect(host.compose_override_config_file)
        .to eq(Rails.root.join('docker-compose.override.yml').to_s)
    end

    # This is the one that actually bit: a clean checkout has no override file at all, so
    # the very first caller got nil.
    context 'when no candidate exists' do
      before { stub_files(missing: %w[compose.override.yml docker-compose.override.yml]) }

      it 'falls back on the first call, not only on later ones' do
        expect(host.compose_override_config_file)
          .to eq(Rails.root.join('compose.override.yml').to_s)
      end

      it 'returns the same value on the first and second call' do
        expect(host.compose_override_config_file).to eq(host.compose_override_config_file)
      end
    end
  end
end
