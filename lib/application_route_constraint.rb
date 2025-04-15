# frozen_string_literal: true

class ApplicationRouteConstraint
  protected

  def log_prefix(method_name)
    "#{self.class.name}##{method_name}"
  end
end
