require 'rails_helper'

RSpec.describe "webhooks/index", type: :view do
  let(:admin_user) { Fabricate(:admin) }
  let(:webhooks) { Fabricate.times(2, :webhook) }

  before(:each) do
    assign(:webhooks, webhooks)
    sign_in admin_user
  end

  it "renders a list of webhooks" do
    render
    cell_selector = 'div>p'
    webhooks.each do |webhook|
      assert_select cell_selector, text: Regexp.new(webhook.url.to_s), count: 1
      assert_select cell_selector, text: Regexp.new(webhook.verification_token.to_s), count: 1
    end
  end
end
