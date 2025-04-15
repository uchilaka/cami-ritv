# frozen_string_literal: true

require_relative 'admin_scope_constraint'
require_relative 'application_route_constraint'

class FlipperApiConstraint < ApplicationRouteConstraint
  def matches?(request)
    Rails.logger.info log_prefix(__method__), request: {
      remote_ip: request.remote_ip,
      forwarded_for: request.forwarded_for
    }

    request.method == 'GET' || admin_scope_constraint.matches?(request)
  end

  def admin_scope_constraint
    @admin_scope_constraint ||= AdminScopeConstraint.new
  end
end
