# frozen_string_literal: true

require 'lib/admin_scope_constraint'

scope :admin, as: :admin do
  constraints AdminScopeConstraint.new do
    mount MissionControl::Jobs::Engine, at: '/jobs'
  end
end
