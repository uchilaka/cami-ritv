# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :request do
  around do |example|
    with_modified_env(APP_DEBUG_MODE: 'no') do
      Rails.application.config.consider_all_requests_local = AppUtils.debug_mode?
      example.run
      Rails.application.config.consider_all_requests_local = true
    end
  end

  describe '#not_found' do
    it 'renders the 404 template' do
      get '/nonexistent_path'
      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('errors/not_found')
    end
  end

  describe '#forbidden', skip: 'The AdminScopeConstraint is failing as expected but returning 404 instead' do
    it 'renders the 403 template' do
      get '/admin/flipper'
      expect(response).to have_http_status(:forbidden)
      expect(response).to render_template('errors/forbidden')
    end
  end
end
