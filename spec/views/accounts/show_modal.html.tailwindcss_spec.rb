# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'accounts/show_modal', type: :view do
  let(:user) { Fabricate :user }
  let(:account) do
    Fabricate(
      :account,
      display_name: 'Display Name',
      slug: 'slugtastic',
      status: 2,
      tax_id: '01-123456789',
      readme: 'MyText',
      users: [user]
    )
  end
  before(:each) do
    sign_in user
    assign(:account, account)
  end

  context 'renders attributes' do
    it 'renders display name' do
      render
      expect(rendered).to match(/Display Name/)
    end

    it 'renders slug' do
      render
      expect(rendered).to match(/slugtastic/)
    end

    it 'renders status' do
      render
      expect(rendered).to match(/2/)
    end

    it 'renders tax id' do
      render
      expect(rendered).to match(/01-123456789/)
    end

    it 'renders readme' do
      render
      expect(rendered).to match(/MyText/)
    end
  end
end
