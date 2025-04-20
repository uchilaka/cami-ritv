# frozen_string_literal: true

require 'lib/admin_scope_constraint'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :demos, only: %i[] do
    collection do
      get 'feature/with-product-screenshot', to: 'demos#feature_with_product_screenshot'
      get 'feature/with-2x2-grid', to: 'demos#feature_with_2x2_grid'
      get 'hello-inertia-rails', to: 'dashboard#index'
      get 'hero/simply-centered', to: 'demos#hero_simply_centered'
      get 'pricing/with-emphasized-tier', to: 'demos#pricing_with_emphasized_tier'
      get 'simple-sign-in', to: 'demos#simple_sign_in'
    end
  end

  get '/protego/:code', to: 'errors#render_static_error'

  root 'demos#hero_simply_centered'

  draw :flipper
end
