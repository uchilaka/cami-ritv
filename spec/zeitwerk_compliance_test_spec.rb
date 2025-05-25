# frozen_string_literal: true

require 'rails_helper'

# See https://guides.rubyonrails.org/testing.html#testing-eager-loading
RSpec.describe 'Zeitwerk compliance test' do
  describe 'Rails.application' do
    describe '.eager_load' do
      it { expect { Rails.application.eager_load! }.not_to raise_error }
    end
  end
end
