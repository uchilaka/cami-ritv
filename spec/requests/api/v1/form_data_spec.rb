# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::V1::FormDataController, type: :request do
  context 'GET /api/v1/form_data' do
    describe '#countries' do
      it 'returns a successful response with a list of countries' do
        get '/api/v1/form_data/countries'
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.first).to include('name', 'alpha2', 'id', 'dial_code')
      end
    end

    describe '#countries_map' do
      it 'returns a successful response with a countries map' do
        get '/api/v1/form_data/countries_map'
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json.values.first).to include('name', 'alpha2', 'id', 'dialCode')
      end
    end
  end
end
