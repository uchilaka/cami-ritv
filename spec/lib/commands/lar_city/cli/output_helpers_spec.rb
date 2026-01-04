# frozen_string_literal: true

require 'rails_helper'
require 'lar_city/cli/output_helpers'
require 'thor'

RSpec.describe LarCity::CLI::OutputHelpers do
  # Inline Thor class used for testing OutputHelpers behavior
  class TestThorClass < Thor
    include ::LarCity::CLI::OutputHelpers

    ::LarCity::CLI::OutputHelpers.define_class_options(self)

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
end
