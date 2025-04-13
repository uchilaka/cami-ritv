Rails.application.routes.draw do
  # get 'inertia-example', to: 'inertia_example#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :demos, only: %i[] do
    collection do
      get 'hero/simply-centered', to: 'demos#hero_simply_centered'
      get 'feature/with-product-screenshot', to: 'demos#feature_with_product_screenshot'
      get 'feature/with-2x2-grid', to: 'demos#feature_with_2x2_grid'
    end
  end

  root 'dashboard#index'
end
