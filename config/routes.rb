# frozen_string_literal: true

require 'lib/admin_scope_constraint'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'dashboard#index'

  draw :flipper
end
