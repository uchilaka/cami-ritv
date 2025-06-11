require 'rails_helper'

RSpec.describe "webhooks/edit", type: :view do
  let(:webhook) {
    Webhook.create!(
      url: "MyString",
      verification_token: "MyString"
    )
  }

  before(:each) do
    assign(:webhook, webhook)
  end

  it "renders the edit webhook form" do
    render

    assert_select "form[action=?][method=?]", webhook_path(webhook), "post" do

      assert_select "input[name=?]", "webhook[url]"

      assert_select "input[name=?]", "webhook[verification_token]"
    end
  end
end
