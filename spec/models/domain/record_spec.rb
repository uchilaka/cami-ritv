# == Schema Information
#
# Table name: domain_records
#
#  id               :uuid             not null, primary key
#  name             :string
#  priority         :integer
#  status           :string           default("active")
#  ttl              :integer          default(1800)
#  type             :string           not null
#  value            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  domain_name_id   :uuid             not null
#  vendor_record_id :string
#
# Indexes
#
#  index_domain_records_on_domain_and_name_and_type  (domain_name_id,name,type)
#  index_domain_records_on_domain_name_id            (domain_name_id)
#  index_domain_records_on_vendor_record_id          (vendor_record_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_name_id => domain_names.id)
#
require 'rails_helper'

RSpec.describe Domain::Record, type: :model do
  subject(:domain_record) { Fabricate.build(:dns_record) }

  describe 'associations' do
    it { is_expected.to belong_to(:domain_name).class_name('Domain::Name').with_foreign_key('domain_name_id') }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[active error inactive pending suspended retired]) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_inclusion_of(:type).in_array(Domain::Record::TYPES) }
    it { is_expected.to validate_presence_of(:value) }
  end

  describe 'state machine' do
    it 'defaults to the "active" state' do
      expect(domain_record).to be_active
      expect(domain_record).to have_state(:active)
    end

    context 'with :alert event' do
      it 'transitions from :active to :error' do
        expect(domain_record).to transition_from(:active).to(:error).on_event(:alert)
      end
    end

    context 'with :activate event' do
      subject(:domain_record) { Fabricate.build(:dns_record, status: 'pending') }

      it 'transitions from :pending to :active' do
        expect(domain_record).to transition_from(:pending).to(:active).on_event(:activate)
      end
    end

    context 'with :deactivate event' do
      it 'transitions from :active to :inactive' do
        expect(domain_record).to transition_from(:active).to(:inactive).on_event(:deactivate)
      end
    end

    context 'with :reactivate event' do
      it 'transitions from :suspended to :active' do
        domain_record.status = 'suspended'
        expect(domain_record).to transition_from(:suspended).to(:active).on_event(:reactivate)
      end

      it 'transitions from :error to :active' do
        domain_record.status = 'error'
        expect(domain_record).to transition_from(:error).to(:active).on_event(:reactivate)
      end
    end

    context 'with :suspend event' do
      it 'transitions from :active to :suspended' do
        expect(domain_record).to transition_from(:active).to(:suspended).on_event(:suspend)
      end

      it 'transitions from :pending to :suspended' do
        domain_record.status = 'pending'
        expect(domain_record).to transition_from(:pending).to(:suspended).on_event(:suspend)
      end
    end

    context 'with :retire event' do
      it 'transitions from :active to :retired' do
        expect(domain_record).to transition_from(:active).to(:retired).on_event(:retire)
      end

      it 'transitions from :pending to :retired' do
        domain_record.status = 'pending'
        expect(domain_record).to transition_from(:pending).to(:retired).on_event(:retire)
      end

      it 'transitions from :suspended to :retired' do
        domain_record.status = 'suspended'
        expect(domain_record).to transition_from(:suspended).to(:retired).on_event(:retire)
      end

      it 'transitions from :error to :retired' do
        domain_record.status = 'error'
        expect(domain_record).to transition_from(:error).to(:retired).on_event(:retire)
      end
    end
  end
end
