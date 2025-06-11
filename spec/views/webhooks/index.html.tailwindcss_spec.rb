require 'rails_helper'

RSpec.describe "webhooks/index", type: :view do
  before(:each) do
    assign(:webhooks, [
      Webhook.create!(
        url: "URL",
        verification_token: "Verification Token"
      ),
      Webhook.create!(
        url: "URL",
        verification_token: "Verification Token"
      )
    ])
  end

  it "renders a list of webhooks" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("URL".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Verification Token".to_s), count: 2
  end
end
