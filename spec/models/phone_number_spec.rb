# frozen_string_literal: true

require 'rails_helper'

describe PhoneNumber do
  subject(:phone_number) do
    described_class.new(value: '+14155552671', country: 'US')
  end

  describe 'validations' do
    it 'is valid with a possible phone number' do
      expect(phone_number).to be_valid
    end

    it 'is invalid with an impossible phone number' do
      phone_number.value = '12345'
      expect(phone_number).not_to be_valid
      expect(phone_number.errors[:value]).to \
        include("'#{phone_number.value}' is not a valid phone number")
    end

    it 'is valid with a blank value' do
      phone_number.value = ''
      expect(phone_number).to be_valid
    end
  end

  describe '.supported_types' do
    it 'returns the supported phone types' do
      expect(described_class.supported_types).to include(:mobile, :fixed_line, :fax, :other)
    end
  end

  describe '#update' do
    it 'updates attributes and saves the record' do
      allow(phone_number).to receive(:save).and_return(true)
      expect(phone_number.update(value: '+14155552672')).to be true
      expect(phone_number.value).to eq('+14155552672')
    end
  end

  describe '#should_validate_possibility?' do
    it 'returns a boolean based on Flipper feature flag' do
      allow(Flipper).to receive(:enabled?).with(:feat__validate_possible_phone_numbers).and_return(true)
      expect(phone_number.should_validate_possibility?).to be true
      allow(Flipper).to receive(:enabled?).with(:feat__validate_possible_phone_numbers).and_return(false)
      expect(phone_number.should_validate_possibility?).to be false
    end
  end
end

