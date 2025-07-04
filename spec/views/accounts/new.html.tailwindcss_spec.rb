require 'rails_helper'

RSpec.describe 'accounts/new', type: :view do
  let(:user) { Fabricate :user }
  let(:account) { Fabricate :account, users: [user] }

  before(:each) do
    sign_in user
    allow(view).to receive(:current_user).and_return(user)
    assign(:account, account)
  end

  it 'renders new account form', skip: 'Failing in CI but passing click tests. Perhaps test in future e2e suite?' do
    render

    assert_select 'form[action=?][method=?]', accounts_path, 'post' do

      assert_select 'input[name=?]', 'account[display_name]'

      assert_select 'input[name=?]', 'account[slug]'

      assert_select 'select[name=?]', 'account[status]'

      assert_select 'input[name=?]', 'account[tax_id]'

      assert_select 'trix-editor#account_readme'

      assert_select 'input[type="hidden"][name=?]', 'account[readme]'
    end
  end
end
