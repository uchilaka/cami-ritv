# frozen_string_literal: true

# TODO: Implement :supports_block_expectations? for this matcher.
#   See doc: https://rspec.info/features/3-13/rspec-expectations/custom-matchers/define-matcher/
RSpec::Matchers.define :have_failed_with_message do |expected_message|
  define_method :supports_block_expectations? do
    true
  end

  define_method :workflow_under_test do |obj|
    # TODO: check block_arg.call and block_given?
    return obj.call if obj.is_a?(Proc)

    obj
  end

  define_method :has_expected_error_message? do |workflow|
    return true if workflow.error == expected_message

    workflow.message == expected_message
  end

  match do |obj|
    workflow = workflow_under_test(obj)
    workflow.failure? && has_expected_error_message?(workflow)
  end

  failure_message do |obj|
    workflow = workflow_under_test(obj)
    "expected workflow to fail with message '#{expected_message}', " \
    "but got error '#{workflow.error}' and message '#{workflow.message}'"
  end

  failure_message_when_negated do |obj|
    _workflow = workflow_under_test(obj)
    "expected workflow not to fail with message '#{expected_message}', " \
    "but it did."
  end
end
