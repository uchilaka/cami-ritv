# frozen_string_literal: true

require 'rails_helper'

# Pundit rspec examples: https://github.com/varvet/pundit?tab=readme-ov-file#rspec
RSpec.describe AccountPolicy, type: :policy do
  let(:user) { Fabricate :user }
  let(:account) { Fabricate :account }
  let(:account_policy) { described_class.new(user, account) }

  describe '#create?' do
    it { expect(account_policy.create?).to be false }
  end

  describe '#accessible_to_user?' do
    it { expect(account_policy.accessible_to_user?).to be false }
  end

  context 'for member direct access via account' do
    before { account.add_member(user) }

    describe '#create?' do
      it { expect(account_policy.create?).to be false }
    end

    describe '#accessible_to_user?' do
      it { expect(account_policy.accessible_to_user?).to be true }
    end
  end

  context 'for member access via "customer" role' do
    before { user.add_role(:customer, account) }

    # Only system admins can create accounts right now. This should be refactored
    # to allow users with the "customer" role to create accounts once the app
    # is ready for that.
    describe '#create?' do
      it { expect(account_policy.create?).to be false }
    end

    describe '#accessible_to_user?', skip: 'TODO: model scope for account access via "customer" role' do
      it { expect(account_policy.accessible_to_user?).to be true }
    end
  end

  context 'for member access via "contact" role' do
    before { user.add_role(:contact, account) }

    describe '#create?' do
      pending 'fails because the user is not an admin'
    end

    describe '#accessible_to_user?' do
      pending 'succeeds because the user is a contact'
    end
  end

  describe AccountPolicy::Scope do
    let(:scope) { Account.all }
    let(:account_policy_scope) { described_class.new(user, scope).resolve }

    it { expect(account_policy_scope).to eq [] }
  end
end
