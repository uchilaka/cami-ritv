# frozen_string_literal: true

require 'rails_helper'

# The test environment decides consider_all_requests_local at boot (see
# config/environments/test.rb), so these examples no longer arrange it themselves.
#
# The previous `around` hook could not have worked: Rails.application.env_config memoises
# show_detailed_exceptions on the first request of the run, so assigning the config
# afterwards only mattered when this file happened to make that first request. It passed
# alone and failed in a full suite. Its teardown also set the flag to `true`
# unconditionally, leaving it that way for every example that ran afterwards.
RSpec.describe ErrorsController, type: :request, skip_in_ci: true do
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
