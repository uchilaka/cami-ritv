# frozen_string_literal: true

RSpec.shared_context 'for phone number testing', shared_context: :metadata do
  def sample_phone_numbers
    @sample_phone_numbers ||=
      YAML
        .load_file('spec/fixtures/sample_phone_numbers.yml')
        .map(&:symbolize_keys)
  end
end
