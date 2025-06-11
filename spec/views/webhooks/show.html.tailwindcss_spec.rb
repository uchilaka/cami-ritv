# frozen_string_literal: true

require 'rails_helper'

# Doc on view specs: https://rspec.info/features/6-0/rspec-rails/view-specs/view-spec/
RSpec.describe 'webhooks/show', type: :view do
  let(:admin_user) { Fabricate(:admin) }
  let(:webhook) { Fabricate(:webhook) }

  before(:each) do
    sign_in admin_user
    assign(:webhook, webhook)
    render
  end

  it 'renders attributes in <p>' do
    expect(rendered).to match(/URL/)
    expect(rendered).to match(/Verification token/)
  end

  # TODO: Pseudocode from LLM - helper methods don't seem to exist
  xit 'renders the webhook details' do
    expect(rendered).to have_selector('h1', text: 'Webhook Details')
    expect(rendered).to have_selector('p', text: webhook.url)
    expect(rendered).to have_selector('p', text: webhook.verification_token)

    expect(rendered).to have_link('Edit', href: edit_webhook_path(webhook))
    expect(rendered).to have_link('Destroy this webhook', href: edit_webhook_path(webhook))
    expect(rendered).to have_link('Back', href: webhooks_path)
  end

  # TODO: Pseudocode from LLM - helper methods don't seem to exist
  xit "has a link to the webhook's edit page" do
    expect(rendered).to have_link('Edit', href: edit_webhook_path(webhook))
  end

  # TODO: Pseudocode from LLM - helper methods don't seem to exist
  xit "has a link to the webhook's index page" do
    expect(rendered).to have_link('Back', href: webhooks_path)
  end

  # TODO: Pseudocode from LLM - helper methods don't seem to exist
  xit 'has a link to destroy the webhook' do
    expect(rendered).to have_selector('form', action: webhook_path(webhook), method: :delete)
    expect(rendered).to have_selector('button', 'Destroy this webhook')
  end
end
