# frozen_string_literal: true

# TODO: Implement a custom RSpec matcher `succeed_with_context_message`

# See doc: https://rspec.info/features/3-13/rspec-expectations/custom-matchers/define-matcher/
# TODO: Implement alias for `have_failed_with_error_message`
#   as `fail_with_context_error`
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
    return true if workflow&.error&.to_s == expected_message

    workflow.message == expected_message
  end

  match do |obj|
    workflow = workflow_under_test(obj)
    workflow.failure? && has_expected_error_message?(workflow)
  end

  failure_message do |obj|
    context = workflow_under_test(obj)
    message_buffer = []
    message_buffer <<
      if context.success?
        "expected workflow to fail with message '#{expected_message}', " \
          "but it succeeded"
      else
        "expected workflow to fail with message '#{expected_message}', " \
          "but got error '#{context.error}'"
      end
    message_buffer << "with message '#{context.message}'" if context.message.present?
    message_buffer.join(' ')
  end

  failure_message_when_negated do |obj|
    _context = workflow_under_test(obj)
    "expected workflow not to fail with message '#{expected_message}', " \
      "but it did."
  end
end
