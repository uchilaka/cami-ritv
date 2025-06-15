# frozen_string_literal: true

require 'rails_helper'

describe AccountContact do
  subject(:contact) do
    described_class.new(
      display_name: 'John Doe',
      email: 'john@example.com',
      given_name: 'John',
      family_name: 'Doe',
      remote_crm_id: 'crm_123'
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(contact).to be_valid
    end

    it 'is invalid without a display_name' do
      contact.display_name = nil
      expect(contact).not_to be_valid
      expect(contact.errors[:display_name]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      contact.email = nil
      expect(contact).not_to be_valid
      expect(contact.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with an invalid email' do
      contact.email = 'invalid-email'
      expect(contact).not_to be_valid
      expect(contact.errors[:email]).to include("#{contact.email} is not a valid email address")
    end
  end

  describe '#attributes' do
    it 'returns a hash of attributes' do
      expect(contact.attributes).to \
        include(
          display_name: 'John Doe',
          email: 'john@example.com',
          given_name: 'John',
          family_name: 'Doe',
          remote_crm_id: 'crm_123'
        )
    end
  end
end

