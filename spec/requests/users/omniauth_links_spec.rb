# frozen_string_literal: true

require 'rails_helper'

# Guards users/shared/omniauth/_links (LAR-324). A provider button must render only when
# the APP_CONFIG_OMNIAUTH_ENABLED toggle is on AND config/initializers/devise.rb actually
# registered the strategy; otherwise the button posts to a middleware that was never mounted.
#
# The initializer runs once at boot, so the registered providers are stubbed via
# Devise.omniauth_configs rather than by reloading Devise with different ENV.
RSpec.describe 'Omniauth sign-in links', type: :request do
  let(:google_authorize_path) { user_google_omniauth_authorize_path }
  let(:registered_providers) { { google: instance_double(Devise::OmniAuth::Config) } }

  before do
    allow(AppUtils).to receive(:omniauth_enabled?).and_return(omniauth_enabled)
    allow(Devise).to receive(:omniauth_configs).and_return(registered_providers)
  end

  shared_examples 'a page gated on the omniauth toggle' do
    context 'when the omniauth toggle is off' do
      let(:omniauth_enabled) { false }

      it 'renders no provider button, even with the provider registered' do
        get page_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include(%(action="#{google_authorize_path}"))
      end
    end

    context 'when the omniauth toggle is on' do
      let(:omniauth_enabled) { true }

      it 'renders a button for each registered provider' do
        get page_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(%(action="#{google_authorize_path}"))
      end

      context 'when the provider credentials were missing at boot' do
        let(:registered_providers) { {} }

        it 'renders no provider button' do
          get page_path

          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include(%(action="#{google_authorize_path}"))
        end
      end
    end
  end

  describe 'GET /users/sign_in' do
    let(:page_path) { new_user_session_path }

    it_behaves_like 'a page gated on the omniauth toggle'
  end

  describe 'GET /users/sign_up' do
    let(:page_path) { new_user_registration_path }

    it_behaves_like 'a page gated on the omniauth toggle'
  end
end
