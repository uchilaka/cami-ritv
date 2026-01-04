# frozen_string_literal: true

require 'rails_helper'
require 'lar_city/cli/output_helpers'
require 'thor'

RSpec.describe LarCity::CLI::OutputHelpers, :time_sensitive do
  # Define inline Thor class for testing
  TestThorClass = Class.new(Thor) do
    include LarCity::CLI::OutputHelpers

    LarCity::CLI::OutputHelpers.define_class_options(self)

    desc 'show_secret', 'Displays the partially masked application secret'
    def show_secret
      partially_masked_secret(app_secret)
    end

    no_commands do
      def app_secret
        ENV.fetch('TEST_APP_SECRET')
      end
    end
  end

  subject(:cmd) { TestThorClass.new }

  describe '#partially_masked_secret' do
    shared_examples 'expected secret masking' do |input, expected_output|
      around do |example|
        with_modified_env(TEST_APP_SECRET: input) { example.run }
      end

      it "masks '#{input}' as '#{expected_output}'" do
        expect(cmd.show_secret).to eq(expected_output)
      end
    end

    it_should_behave_like 'expected secret masking', 'myvalue', 'm*****e'
    it_should_behave_like 'expected secret masking', 'my-secret-value', 'my-*********lue'
    it_should_behave_like 'expected secret masking', 'my#Longer#secret#value', 'my#************lue'
    it_should_behave_like 'expected secret masking', 'my#V3ryMuchLongerThatWillBeCutOff#secret#value', 'my#************lue'
  end

  describe '#extract_timestamp' do
    subject(:result) { cmd.extract_timestamp(filename) }

    let(:expected_time) do
      Time.new(2024, 6, 15, 12, 30, 45, "-0400")
    end

    around do |example|
      travel_to(expected_time) { example.run }
    end

    context 'with valid filename format' do
      let(:filename) { 'backup_(20240615.123045-0400).sql' }

      it { is_expected.to eq(expected_time) }
    end

    context 'with unsupported format' do
      let(:filename) { 'backup_15-06-2024_12-30-45.sql' }

      it { is_expected.to be_nil }
    end

    context 'with invalid filename' do
      let(:filename) { 'random_file_name.txt' }

      it { is_expected.to be_nil }
    end
  end
end
