# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V1::FormData', type: :request do
  path '/api/v1/form_data/countries' do
    get 'Retrieves a list of countries' do
      tags 'Form Data'
      produces 'application/json'

      response '200', 'countries found' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/country' }

        run_test! do |response|
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json).to be_an(Array)
          expect(json.first).to include('name', 'alpha2', 'id', 'dial_code')
        end
      end
    end
  end

  path '/api/v1/form_data/countries_map' do
    get 'Retrieves a map of countries' do
      tags 'Form Data'
      produces 'application/json'

      response '200', 'countries map found' do
        schema type: :object,
               additionalProperties: { '$ref' => '#/components/schemas/country_mapped' }

        run_test! do |response|
          expect(response).to have_http_status(:success)
          json = JSON.parse(response.body)
          expect(json).to be_a(Hash)
          expect(json.values.first).to include('name', 'alpha2', 'id', 'dialCode')
        end
      end
    end
  end
end
