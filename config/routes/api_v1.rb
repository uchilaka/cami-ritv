# frozen_string_literal: true

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :features, only: %i[index], defaults: { format: :json }
    resources :form_data, only: %i[] do
      collection do
        get :countries, defaults: { format: :json }
        get :countries_map, defaults: { format: :json }
      end
    end
  end
end
