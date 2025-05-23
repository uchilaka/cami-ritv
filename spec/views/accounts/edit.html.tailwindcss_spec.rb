# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accounts/edit', type: :view do
  let(:user) { Fabricate :user }
  let(:account) { Fabricate :account, users: [user] }

  before(:each) do
    sign_in user
    allow(view).to receive(:current_user).and_return(user)
    # TODO: This isn't working - theory as at this writing is
    #   the policy singleton method is not implemented in
    #   ActionView::Base but is loaded a different way
    allow(view).to receive(:policy) { |record| ApplicationPolicy.new(user, record) }
    assign(:account, account)
  end

  # TODO: ActionView::Template::Error: undefined method `policy'
  xit 'renders the edit account form' do
    render

    assert_select 'form[action=?][method=?]', account_path(account), 'post' do
      assert_select 'input[name=?]', 'account[display_name]'

      assert_select 'input[name=?]', 'account[slug]'

      assert_select 'select[name=?]', 'account[status]'

      assert_select 'input[name=?]', 'account[tax_id]'

      assert_select 'trix-editor#account_readme'

      assert_select 'input[type="hidden"][name=?]', 'account[readme]'
    end
  end
end
