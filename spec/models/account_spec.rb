# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id            :uuid             not null, primary key
#  discarded_at  :datetime
#  display_name  :string
#  email         :string
#  metadata      :jsonb
#  phone         :jsonb
#  readme        :text
#  slug          :string
#  status        :integer
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  parent_id     :uuid
#  remote_crm_id :string
#  tax_id        :string
#
# Indexes
#
#  by_account_email_if_set         (email) UNIQUE NULLS NOT DISTINCT WHERE (email IS NOT NULL)
#  index_accounts_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => accounts.id)
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  include_context 'for phone number testing'

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

  describe '#add_member' do
    let(:account) { Fabricate(:account) }
    let(:user) { Fabricate(:user) }

    it 'adds a user to the account members' do
      expect {
        account.add_member(user)
      }.to change { account.members.count }.by(1)

      expect(account.members).to include(user)
    end
  end

  describe '#crm_url' do
    let(:account) { Fabricate(:account, remote_crm_id: '12345') }

    before do
      allow(Rails.application.credentials).to receive(:zoho).and_return(double(org_id: '877691058'))
    end

    it 'returns the CRM URL when remote_crm_id is present' do
      expect(account.crm_url).to eq("https://crm.zoho.com/crm/org877691058/tab/Accounts/12345")
    end

    it 'returns nil when remote_crm_id is blank' do
      account.update!(remote_crm_id: nil)
      expect(account.crm_url).to be_nil
    end
  end

  describe '#crm_relevant_changes?' do
    let(:account) { Fabricate(:account) }

    # No changes initially
    it { expect(account.send(:crm_relevant_changes?)).to be_falsey }

    # Changes to attributes that are not relevant for CRM
    it { expect { account.slug = Faker::Internet.slug }.not_to(change { account.send(:crm_relevant_changes?) }) }

    # Changes to attributes that are relevant for CRM
    it do
      expect { account.email = 'new@example.com' }.to \
        change { account.send(:crm_relevant_changes?) }.from(false).to(true)
    end

    it do
      expect { account.display_name = Faker::Name.gender_neutral_first_name }.to \
        change { account.send(:crm_relevant_changes?) }.from(false).to(true)
    end

    it do
      expect { account.readme = Faker::Lorem.paragraph }.to \
        change { account.send(:crm_relevant_changes?) }.from(false).to(true)
    end

    it do
      expect { account.tax_id = Faker::Company.ein }.to \
        change { account.send(:crm_relevant_changes?) }.from(false).to(true)
    end

    it do
      expect { account.phone = PhoneNumber.new(value: sample_phone_numbers.sample, resource: account) }.to \
        change { account.send(:crm_relevant_changes?) }.from(false).to(true)
    end
  end

  describe '#format_tax_id' do
    let(:account) { Fabricate.build(:account, tax_id: 'ax-12345') }

    it 'upcases the tax_id before validation' do
      account.valid?
      expect(account.tax_id).to eq('AX-12345')
    end
  end

  describe '#push_to_crm' do
    let(:account) { Fabricate(:account) }

    before do
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      # Add the feature flag if it doesn't exist
      Flipper.add(:feat__push_updates_to_crm) unless Flipper.exist?(:feat__push_updates_to_crm)

      # Enable the feature flag by default
      Flipper.enable(:feat__push_updates_to_crm)
    end

    it 'enqueues a Zoho::UpsertAccountJob with the correct parameters' do
      expect {
        account.send(:push_to_crm)
      }.to have_enqueued_job(Zoho::UpsertAccountJob)
        .with(account.id)
        .on_queue('critical')
        .at(a_value_within(1.second).of(5.seconds.from_now))
    end

    it 'does not enqueue job when feature flag is disabled' do
      Flipper.disable(:feat__push_updates_to_crm)

      expect {
        account.send(:push_to_crm)
      }.not_to have_enqueued_job(Zoho::UpsertAccountJob)
    end
  end

  describe '#primary_users_confirmed?' do
    it 'returns true by default' do
      account = Fabricate(:account)
      expect(account.primary_users_confirmed?).to be true
    end
  end

  describe '#readme_body_changed?' do
    let(:initial_content) { 'Initial readme content' }
    let(:account) { Fabricate(:account, readme: initial_content) }

    it 'returns true when the readme body has changed' do
      account.readme = 'New readme content'
      expect(account.readme_body_changed?).to be_truthy
    end

    it 'returns false when the readme body has not changed' do
      account.readme = initial_content
      expect(account.readme_body_changed?).to be_falsey
    end
  end

  describe '#readme' do
    let(:account) { Fabricate(:account) }

    it 'returns the readme content' do
      account.readme = Faker::Lorem.paragraph
      expect(account.readme).to be_a(ActionText::RichText)
    end

    it 'is nil by default' do
      expect(account.readme).to be_nil
    end

    it 'supports ActiveModel::Dirty *_changed?' do
      account.readme = 'New readme content'
      expect(account.readme&.send(:body_changed?)).to be_truthy
    end

    it do
      account.readme = '**New** readme content'
      expect(account.readme.to_s).to include('**New** readme content')
    end

    pending "Supports markdown input and HTML output that's safe-ish to render"
  end

  describe '.ransackable_attributes' do
    it 'returns searchable attributes' do
      expect(described_class.ransackable_attributes).to match_array(
        %w[display_name email slug tax_id]
      )
    end
  end

  describe '.ransackable_associations' do
    it 'returns searchable associations' do
      expect(described_class.ransackable_associations).to match_array(
        %w[invoices members rich_text_readme roles]
      )
    end
  end
end
