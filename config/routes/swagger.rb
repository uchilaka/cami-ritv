# frozen_string_literal: true

require 'lib/admin_scope_constraint'

# TODO: Implement a DeveloperAccessConstraint for the API docs
scope :admin, as: :admin do
  constraints AdminScopeConstraint.new do
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
end
