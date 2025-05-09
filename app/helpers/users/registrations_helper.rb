# frozen_string_literal: true

module Users
  module RegistrationsHelper
    attr_accessor :global_privilege_level,
                  :most_privileged_role,
                  :available_roles

    def supported_roles
      User::SUPPORTED_ROLES
    end

    def available_role_labels
      @available_role_labels ||= available_roles.map { |_role, (_privilege_level, label)| label }
    end
  end
end
