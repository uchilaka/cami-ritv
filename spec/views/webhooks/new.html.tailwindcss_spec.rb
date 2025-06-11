require 'rails_helper'

RSpec.describe "webhooks/new", type: :view do
  before(:each) do
    assign(:webhook, Webhook.new(
      url: "MyString",
      verification_token: "MyString"
    ))
  end

  it "renders new webhook form" do
    render

    assert_select "form[action=?][method=?]", webhooks_path, "post" do

      assert_select "input[name=?]", "webhook[url]"

      assert_select "input[name=?]", "webhook[verification_token]"
    end
  end
end
