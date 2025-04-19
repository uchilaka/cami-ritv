# frozen_string_literal: true

module LarCity
  module AccessControlled
    extend ActiveSupport::Concern

    included do
      attr_accessor :most_privileged_role, :global_privilege_level, :available_roles
    end

    protected

    def calculate_most_privileged_role
      return [] unless current_user

      # Check for highest privilege role that the user has
      @most_privileged_role, role_params = ordered_role_entries.find do |(role, _role_tuple)|
        resource.has_role?(role)
      end
      if most_privileged_role.blank?
        @most_privileged_role, role_params = ordered_role_entries.find { |(role, _role_tuple)| role == :user }
      end

      [@most_privileged_role, role_params]
    end

    def set_global_privilege_level
      _, role_params = calculate_most_privileged_role
      @global_privilege_level, _most_privileged_role_label = role_params
    end

    def set_available_roles
      set_global_privilege_level unless @most_privileged_role.present?
      @available_roles ||= ordered_role_entries.select do |_role, role_tuple|
        role_tuple[0] <= global_privilege_level
      end
    end

    # List of supported roles prioritized by their privilege level
    def ordered_role_entries
      @ordered_role_entries ||= User::SUPPORTED_ROLES.entries.sort do |(_role_a, role_a_tuple), (_role_b, role_b_tuple)|
        role_b_tuple[0] <=> role_a_tuple[0]
      end
    end
  end
end
