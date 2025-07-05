# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'webhooks/edit', type: :view do
  let(:admin_user) { Fabricate(:admin) }
  let(:webhook) { Fabricate(:webhook) }

  before(:each) do
    assign(:webhook, webhook)
    sign_in admin_user
  end

  around do |example|
    with_modified_env(HOSTNAME: 'accounts.larcity.test') do
      example.run
    end
  end

  it 'renders the edit webhook form' do
    render

    assert_select 'form[action=?][method=?]', webhook_path(webhook), 'post' do
      assert_select 'input[name=?]', 'webhook[url]'

      assert_select 'input[name=?]', 'webhook[verification_token]'

      assert_select 'input[name=?]', 'webhook[integration_id]'

      assert_select 'input[name=?]', 'webhook[integration_name]'

      assert_select 'input[name=?]', 'webhook[verification_token]'
    end
  end
end
