# frozen_string_literal: true

require_relative 'restricted_ips_constraint'

class AdminScopeConstraint
  attr_reader :allow_by_ip

  def initialize
    @allow_by_ip = RestrictedIpsConstraint.new
  end

  def matches?(request)
    return true if Rails.env.development?

    allow_by_ip.matches?(request)
  end
end
