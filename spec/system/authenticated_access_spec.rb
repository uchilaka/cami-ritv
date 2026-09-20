# frozen_string_literal: true

require 'rails_helper'

# Proves session-backed authentication works through a real browser, which request specs
# cannot show: the browser holds the cookie and makes its own requests to the
# app-under-test running in a separate thread.
RSpec.describe 'Authenticated access', browser: true do
  let(:user) { Fabricate(:user) }

  context 'when signed out' do
    it 'redirects to the sign-in page', :js do
      visit '/invoices'

      expect(page).to have_current_path(%r{/users/sign_in})
    end
  end

  context 'when signed in' do
    before { login_as(user, scope: :user) }

    it 'renders the protected page', :js do
      visit '/invoices'

      expect(page).to have_current_path('/invoices')
      expect(page).to have_css('h1', text: 'Invoices')
    end
  end
end
