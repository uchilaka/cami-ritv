# frozen_string_literal: true

require 'lib/admin_scope_constraint'

Rails.application.routes.draw do
  namespace :api do
    namespace :v2, defaults: { format: :json } do
      namespace :crm do
        resource :accounts, only: [] do
          member do
            put ':id', as: :update, action: :update
            patch ':id', action: :update
          end
        end
      end

      namespace :webhooks, only: [] do
        post 'notion/events', controller: 'notion/events', action: :create
        patch 'notion/events/:id/deal', controller: 'notion/events', action: :deal, as: :notion_event_deal
      end
    end
  end

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
  resources :invoices, except: %i[destroy] do
    member do
      get :show_modal
    end

    collection do
      post :search
    end
  end

  resources :accounts, except: %i[destroy] do
    member do
      get :show_modal
      get :navigate_to_crm_modal
      get :show_li_actions
      put 'update/:integration', as: :update_integration, action: :push
    end
  end

  resources :demos, only: %i[] do
    collection do
      get 'blog-highlights', to: 'demos#blog_highlights'
      get 'content-sections', to: 'demos#content_sections'
      get 'feature/with-product-screenshot', to: 'demos#feature_with_product_screenshot'
      get 'feature/with-2x2-grid', to: 'demos#feature_with_2x2_grid'
      get 'hello-inertia-rails', to: 'dashboard#index'
      get 'hero/simply-centered', to: 'demos#hero_simply_centered'
      get 'newsletter', to: 'demos#newsletter'
      get 'pricing/with-emphasized-tier', to: 'demos#pricing_with_emphasized_tier'
      get 'simple-sign-in', to: 'demos#simple_sign_in'
      get 'testimonials', to: 'demos#testimonials'
      get 'work-with-us', to: 'demos#work_with_us'
    end
  end

  resources :webhooks do
    # member do
    #   get :records, to: 'webhooks/records#index', as: :records
    # end
    resources :records, controller: 'webhooks/records', only: %i[index show]

    resources :events, controller: 'webhooks/events', only: %i[index show] do
      # member do
      #   get :record, to: 'webhooks/records#show', as: :record
      # end
      resources :records, controller: 'webhooks/records', only: %i[show]
    end
  end

  get '/about-us', to: 'lobby#about_us'
  get '/consultation/:subject', to: 'lobby#consultation'
  get '/protego/:code', to: 'errors#render_static_error'
  get '/video', to: 'lobby#background_video'

  root 'lobby#landing_page'

  draw :flipper
  draw :mission_control
  draw :swagger
  draw :api_v1
end
