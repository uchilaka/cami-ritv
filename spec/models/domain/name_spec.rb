# == Schema Information
#
# Table name: domain_names
#
#  id         :uuid             not null, primary key
#  hostname   :string           not null
#  status     :string           default("active")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_domains_on_name  (hostname) UNIQUE
#
require 'rails_helper'

RSpec.describe Domain::Name, type: :model do
  subject(:domain_name) { Fabricate.build(:domain_name) }

  describe 'associations' do
    it { is_expected.to have_many(:records).class_name('Domain::Record').with_foreign_key('domain_name_id').dependent(:destroy) }
  end

  describe 'validations' do
    # To properly test uniqueness, a record needs to be created first.
    # It's assumed a factory for domain_name exists.
    subject(:persisted_domain_name) { Fabricate(:domain_name, hostname: 'example.com') }

    it { is_expected.to validate_presence_of(:hostname) }
    it { expect(persisted_domain_name).to validate_uniqueness_of(:hostname) }

    it 'validates inclusion of status in the defined statuses' do
      # The list of statuses is derived from the AASM state machine definition.
      statuses = %w[active inactive error pending suspended retired]
      is_expected.to validate_inclusion_of(:status).in_array(statuses)
    end
  end

  describe 'state machine' do
    it 'defaults to the "active" state' do
      expect(domain_name).to be_active
      expect(domain_name).to have_state(:active)
    end

    context 'with :alert event' do
      it 'transitions from :active to :error' do
        expect(domain_name).to transition_from(:active).to(:error).on_event(:alert)
      end
    end

    context 'with :activate event' do
      subject(:domain_name) { Fabricate.build(:domain_name, status: 'pending') }

      it 'transitions from :pending to :active' do
        expect(domain_name).to transition_from(:pending).to(:active).on_event(:activate)
      end
    end

    context 'with :deactivate event' do
      it 'transitions from :active to :inactive' do
        expect(domain_name).to transition_from(:active).to(:inactive).on_event(:deactivate)
      end
    end

    context 'with :reactivate event' do
      it 'transitions from :suspended to :active' do
        domain_name.status = 'suspended'
        expect(domain_name).to transition_from(:suspended).to(:active).on_event(:reactivate)
      end

      it 'transitions from :error to :active' do
        domain_name.status = 'error'
        expect(domain_name).to transition_from(:error).to(:active).on_event(:reactivate)
      end
    end

    context 'with :suspend event' do
      it 'transitions from :active to :suspended' do
        expect(domain_name).to transition_from(:active).to(:suspended).on_event(:suspend)
      end

      it 'transitions from :pending to :suspended' do
        domain_name.status = 'pending'
        expect(domain_name).to transition_from(:pending).to(:suspended).on_event(:suspend)
      end
    end

    context 'with :retire event' do
      it 'transitions from :active to :retired' do
        expect(domain_name).to transition_from(:active).to(:retired).on_event(:retire)
      end

      it 'transitions from :pending to :retired' do
        domain_name.status = 'pending'
        expect(domain_name).to transition_from(:pending).to(:retired).on_event(:retire)
      end

      it 'transitions from :suspended to :retired' do
        domain_name.status = 'suspended'
        expect(domain_name).to transition_from(:suspended).to(:retired).on_event(:retire)
      end

      it 'transitions from :error to :retired' do
        domain_name.status = 'error'
        expect(domain_name).to transition_from(:error).to(:retired).on_event(:retire)
      end
    end
  end
end
