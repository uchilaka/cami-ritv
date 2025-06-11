require 'rails_helper'

RSpec.describe "webhooks/new", type: :view do
  let(:admin_user) { Fabricate(:admin) }
  let(:webhook) { Fabricate(:webhook) }

  before(:each) do
    sign_in admin_user
    assign(:webhook, webhook)
  end

  xit "renders new webhook form" do
    render

    assert_select "form[action=?][method=?]", webhooks_path, "post" do

      assert_select "input[name=?]", "webhook[url]"

      assert_select "input[name=?]", "webhook[verification_token]"
    end
  end
end
