# frozen_string_literal: true

require 'lib/admin_scope_constraint'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users,
             controllers: {
               sessions: 'users/passwordless',
               passwords: 'users/passwords',
               registrations: 'users/registrations',
               confirmations: 'users/confirmations',
               unlocks: 'users/unlocks',
               omniauth_callbacks: 'users/omniauth/callbacks',
             }
  devise_scope :user do
    get 'users/fallback/sign_in', as: :new_user_fallback_session, to: 'users/sessions#new'
    post 'users/fallback/sign_in', as: :user_fallback_session, to: 'users/sessions#create'
    delete 'users/fallback/sign_out', as: :destroy_user_fallback_session, to: 'users/sessions#destroy'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :demos, only: %i[] do
    collection do
      get 'feature/with-product-screenshot', to: 'demos#feature_with_product_screenshot'
      get 'feature/with-2x2-grid', to: 'demos#feature_with_2x2_grid'
      get 'hello-inertia-rails', to: 'dashboard#index'
      get 'hero/simply-centered', to: 'demos#hero_simply_centered'
      get 'pricing/with-emphasized-tier', to: 'demos#pricing_with_emphasized_tier'
      get 'simple-sign-in', to: 'demos#simple_sign_in'
      get 'work-with-us', to: 'demos#work_with_us'
    end
  end

  get '/about-us', to: 'lobby#about_us'
  get '/protego/:code', to: 'errors#render_static_error'
  get '/video', to: 'lobby#background_video'

  root 'lobby#landing_page'

  draw :flipper
end
