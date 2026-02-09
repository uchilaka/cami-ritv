# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'support/custom_workflow_context_matchers' do
  # This class will simulate success or failure based on the context.
  # It uses the :mock_failure flag from the context to determine behavior.
  # When :mock_failure is true, it fails with a mock error message.
  # Otherwise, it succeeds and sets a mock workflow message.
  class TestWorkflow
    include Interactor

    delegate :failure?, :mock_error_message, :success?, to: :context

    def call
      if should_mock_failure?
        # Simulate failure for testing purposes
        error = StandardError.new(mock_error_message)
        context.fail!(error:)
        raise error
      end

      # Assume success
      context.message = mock_workflow_message
    ensure
      return if success?

      # Assume failed
      context.fail!(message: mock_error_message)
    end

    def should_mock_failure?
      context.mock_failure == true
    end
  end

  subject(:result) { TestWorkflow.call(mock_failure:, mock_error_message:) }

  let(:mock_failure) { nil }
  let(:mock_error_message) { 'Mock error message' }
  let(:mock_workflow_message) { 'Mock workflow message' }

  describe '#have_failed_with_message' do
    it 'supports block expectations' do
      expect {
        expect { result }.not_to have_failed_with_message(mock_error_message)
      }.not_to raise_error
    end

    context 'when the workflow fails with the expected message' do
      let(:mock_failure) { true }

      it 'matches successfully' do
        expect(result).to have_failed_with_message(mock_error_message)
      end
    end

    context 'when the workflow fails with a different message' do
      let(:mock_failure) { true }
      let(:different_error_message) { 'A different error message' }
      let(:actual_error_regex) do
        %r{expected workflow to fail with message '#{different_error_message}', but got error '#{mock_error_message}'}
      end

      it 'does not match and provides a useful failure message' do
        expect {
          expect(result).to have_failed_with_message(different_error_message)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, actual_error_regex)
      end
    end

    context 'when the workflow succeeds' do
      let(:mock_failure) { false }
      let(:actual_error_regex) do
        %r{expected workflow to fail with message '#{mock_error_message}', but it succeeded}
      end

      subject(:result) { TestWorkflow.call(mock_failure:) }

      it 'does not match and provides a useful failure message' do
        expect {
          expect(result).to have_failed_with_message(mock_error_message)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, actual_error_regex)
      end
    end
  end
end
