# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :uuid             not null, primary key
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :uuid
#
# Indexes
#
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource                                (resource_type,resource_id)
#
require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:role_name) { 'doodad' }

  it { is_expected.to have_and_belong_to_many(:users).join_table('users_roles') }
  it { is_expected.to have_and_belong_to_many(:accounts) }

  describe '#users' do
    let(:user) { Fabricate :user }
    let(:account) { Fabricate :account }

    context 'when granting a customer role to a user on an invoice' do
      let(:role_name) { 'customer' }
      let(:resource) { Fabricate :invoice, invoiceable: account }

      context "who isn't a member on the account" do
        describe '#has_role?' do
          it do
            expect { user.add_role(role_name, resource) }.to \
              change { user.has_role?(role_name, resource) }.to(true)
          end
        end
      end

      context 'who is a member on the account' do
        let(:account) { Fabricate :account, users: [user] }

        describe '#has_role?' do
          pending 'works the same?'
        end
      end
    end
  end
end
