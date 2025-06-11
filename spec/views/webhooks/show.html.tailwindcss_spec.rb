require 'rails_helper'

RSpec.describe "webhooks/show", type: :view do
  before(:each) do
    assign(:webhook, Webhook.create!(
      url: "URL",
      verification_token: "Verification Token"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/URL/)
    expect(rendered).to match(/Verification Token/)
  end
end
