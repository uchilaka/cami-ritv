# frozen_string_literal: true

require 'rails_helper'
require 'lar_city/cli/output_helpers'
require 'thor'

RSpec.describe LarCity::CLI::OutputHelpers do
  # Inline Thor class used for testing OutputHelpers behavior
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

  describe "#pretend?" do
    subject(:cmd) { TestThorClass.new(cmd_args, **options) }

    it("is a protected method") { expect(cmd.protected_methods).to include(:pretend?) }

    let(:result) { cmd.send(:pretend?) }
    let(:cmd_args) { [] }
    let(:options) { {} }

    context "when dry_run is enabled" do
      let(:options) { { dry_run: true } }

      it { expect(result).to be true }
    end

    context "when dry_run is disabled" do
      let(:options) { { dry_run: false } }

      it { expect(result).to be false }
    end
  end

  describe "#debug?" do
    subject(:cmd) { TestThorClass.new(cmd_args, **options) }

    it("is a protected method") { expect(cmd.protected_methods).to include(:debug?) }

    let(:result) { cmd.send(:debug?) }
    let(:cmd_args) { [] }
    let(:options) { {} }

    context "when verbose is enabled" do
      let(:options) { { verbose: true } }

      it { expect(result).to be true }
    end

    context "when verbose is disabled" do
      let(:options) { { verbose: false } }

      it { expect(result).to be false }
    end
  end

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

  describe "#tally" do
    subject(:result) { cmd.tally(set, collection_class.name) }
    let(:collection_class) { Webhook }

    context "with no items" do
      let(:set) { Webhook.none }

      it { is_expected.to eq "0 Webhooks" }
    end

    context "with a single item" do
      let(:set) { Fabricate.times(1, :webhook) }

      it { is_expected.to eq "1 Webhook" }
    end

    context "with multiple items" do
      let(:set) { Fabricate.times(3, :webhook) }

      it { is_expected.to eq "3 Webhooks" }
    end
  end

  describe "#range" do
    subject(:result) { cmd.range(set) }

    context "with no items" do
      let(:set) { Webhook.none }

      it { is_expected.to be_nil }
    end

    context "with a single item" do
      let(:set) { Fabricate.times(1, :webhook) }

      it { is_expected.to eq "[1]" }
    end

    context "with multiple items" do
      let(:set) { Fabricate.times(3, :webhook) }
      let(:ids) { set.pluck(:id).sort }

      it { is_expected.to eq "[1-3]" }
    end
  end
end
