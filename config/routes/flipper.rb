# frozen_string_literal: true

require_relative '../../lib/flipper_api_constraint'

constraints FlipperApiConstraint.new do
  mount Flipper::Api.app(Flipper) => '/flipper/api'
end

scope :admin, as: :admin do
  constraints AdminScopeConstraint.new do
    mount Flipper::UI.app(Flipper) => '/flipper'
  end
end
