# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                  :uuid             not null, primary key
#  discarded_at        :datetime
#  display_name        :string
#  email               :string
#  last_sent_to_crm_at :datetime
#  metadata            :jsonb
#  phone               :jsonb
#  readme              :text
#  slug                :string
#  status              :integer
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :uuid
#  remote_crm_id       :string
#  tax_id              :string
#
# Indexes
#
#  by_account_email_if_set                (email) UNIQUE NULLS NOT DISTINCT WHERE (email IS NOT NULL)
#  index_accounts_on_discarded_at         (discarded_at)
#  index_accounts_on_last_sent_to_crm_at  (last_sent_to_crm_at)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => accounts.id)
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  subject { Fabricate :account }

  # around do |example|
  #   Sidekiq::Testing.inline! { example.run }
  # end

  it { should validate_presence_of :display_name }
  it { should validate_presence_of :slug }
  it { should validate_uniqueness_of(:slug).case_insensitive }
  it { should have_and_belong_to_many(:members) }
  it { should have_many(:invoices) }

  shared_examples 'adding a role on an invoice is supported' do |role_name|
    let(:account) { Fabricate :account }
    let(:invoice) { Fabricate :invoice }

    subject { account.add_role(role_name, invoice) }

    context "when role = #{role_name}" do
      it { expect { subject }.to change { account.has_role?(role_name, invoice) }.to(true) }
      it { expect { subject }.to change { invoice.roles.count }.by(1) }
    end
  end

  it_should_behave_like 'adding a role on an invoice is supported', :customer
  it_should_behave_like 'adding a role on an invoice is supported', :contact

  # Scenarios
  context 'with a parent account' do
    let(:parent) { Fabricate :account }
    let(:account) { Fabricate(:account, parent:) }

    it { expect(account.parent).to eq parent }
    it { expect(parent.dupes).to include(account) }
  end

  # Instance methods / accessors
  describe '#modal_dom_id' do
    let(:account) { Fabricate :account }

    subject { account.modal_dom_id }

    it { expect(subject).to eq "#{account.model_name.singular}--modal|#{account.id}|" }

    context 'with content_type' do
      let(:content_type) { 'content' }

      subject { account.modal_dom_id(content_type:) }

      it { expect(subject).to eq "#{account.model_name.singular}--#{content_type}--modal|#{account.id}|" }
    end
  end

  describe '#remote_crm_id' do
    context 'when blank' do
      subject { Fabricate :account, remote_crm_id: '' }

      it { expect(subject).to be_valid }
    end

    context 'with several blank records' do
      let!(:account) { Fabricate :account, remote_crm_id: '' }

      subject { Fabricate.build :account, remote_crm_id: '' }

      it { expect(subject).to be_valid }
    end

    context 'when present in the database (case insensitive)' do
      let!(:account) { Fabricate :account, remote_crm_id: 'ZohoCRM.123456789' }

      subject { Fabricate.build :account, remote_crm_id: 'zohocrm.123456789' }

      it { expect(subject).to be_invalid }

      it 'fails validation on save' do
        expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#tax_id' do
    context 'when blank' do
      subject { Fabricate :account, tax_id: '' }

      it { expect(subject).to be_valid }
    end

    context 'when present in the database (case insensitive)' do
      let!(:account) { Fabricate :account, tax_id: 'ax-123456789' }

      subject { Fabricate.build :account, tax_id: 'AX-123456789' }

      it { expect(subject).to be_invalid }

      it 'fails validation on save' do
        expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#status' do
    it { transition_from(%i[demo draft guest]).to(:active).on_event(:activate) }
    it { transition_from(%i[active payment_due overdue]).to(:paid).on_event(:enroll) }
    it { transition_from(%i[active payment_due overdue]).to(:suspended).on_event(:suspend) }
    it { transition_from(%i[suspended overdue deactivated]).to(:active).on_event(:reactivate) }
    it { transition_from(%i[payment_due overdue suspended]).to(:deactivated).on_event(:deactivate) }

    it 'is draft by default' do
      expect(subject.status).to eq 'draft'
    end

    context 'is invalid', skip: 'TODO: this error seems to be behaving differently in CI test' do
      subject { Fabricate.build :account, status: 'not_valid' }

      it { expect { subject }.to raise_error(ArgumentError, "'not_valid' is not a valid status") }
    end

    context 'is nil' do
      let(:account) { Fabricate.build :account, status: nil }

      it { expect(account.status).to eq 'draft' }
    end

    context 'is valid' do
      let(:account) { Fabricate.build :account, status: 'demo' }

      it { expect(account).to be_valid }

      it { expect(account.status).to eq('demo') }
    end
  end

  describe '#invoices', skip: 'pending' do
    let(:account) { Fabricate :account }
    let(:invoice) { Fabricate :invoice }

    pending 'can be accessed via "customer" role'
  end

  describe '#actions' do
    subject { Fabricate :account }

    it 'includes the expected action hashes' do
      expect(subject.actions).to \
        match(
          back: hash_including(
            dom_id: anything,
            http_method: 'GET',
            label: 'Back to Accounts',
            url: anything
          ),
          delete: hash_including(
            dom_id: anything,
            http_method: 'DELETE',
            label: 'Delete',
            url: anything
          ),
          edit: hash_including(
            dom_id: anything,
            http_method: 'GET',
            label: 'Edit',
            url: anything
          ),
          show: hash_including(
            dom_id: anything,
            http_method: 'GET',
            label: 'Account details',
            url: anything
          )
        )
    end

    it { expect(subject.actions.dig(:back, :url)).to match(%r{/accounts\?locale=en$}) }
    it { expect(subject.actions.dig(:delete, :url)).to match(%r{/accounts/#{subject.id}.json\?locale=en$}) }
    it { expect(subject.actions.dig(:edit, :url)).to match(%r{/accounts/#{subject.id}\?locale=en$}) }
    it { expect(subject.actions.dig(:show, :url)).to match(%r{/accounts/#{subject.id}\?locale=en$}) }
  end

  # Class methods
  describe '.fuzzy_search_predicate_key' do
    let(:fields) { %w[display_name email] }

    it do
      expect(described_class.fuzzy_search_predicate_key(*fields)).to \
        eq 'display_name_or_email_cont'
    end

    context 'with 1 field' do
      let(:fields) { %w[email] }

      it do
        expect(described_class.fuzzy_search_predicate_key(*fields)).to \
          eq 'email_cont'
      end

      context 'when association is provided' do
        let(:association) { 'Account' }

        subject do
          described_class.fuzzy_search_predicate_key(*fields, association:)
        end

        it { expect(subject).to eq 'accounts_email_cont' }
      end
    end

    context 'with several fields' do
      let(:fields) { %w[email display_name] }

      it do
        expect(described_class.fuzzy_search_predicate_key(*fields)).to \
          eq 'display_name_or_email_cont'
      end

      context 'when association is provided' do
        let(:association) { 'Account' }

        subject do
          described_class.fuzzy_search_predicate_key(*fields, association:)
        end

        it do
          expect(subject).to \
            eq 'accounts_display_name_or_accounts_email_cont'
        end
      end
    end
  end
end
