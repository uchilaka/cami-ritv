# frozen_string_literal: true

module Users
  # Kind of ancient, but hopefully still useful: https://gist.github.com/kinopyo/2343176
  class RegistrationsController < Devise::RegistrationsController
    include LarCity::AccessControlled

    before_action :assign_default_role, only: %i[edit update]
    before_action :set_global_privilege_level,
                  :set_available_roles, only: %i[edit update]
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]
    before_action :set_minimum_password_length_hint

    # # GET /resource/sign_up
    # def new
    #   super
    # end
    #
    # # POST /resource
    # def create
    #   super
    # end
    #
    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    def update
      super

      Rails.logger.info 'Role parameters', role_params:
    end
    #
    # # DELETE /resource
    # def destroy
    #   super
    # end
    #
    # # GET /resource/cancel
    # def cancel
    #   super
    # end

    protected

    def set_minimum_password_length_hint
      @minimum_password_length_hint ||=
        if @minimum_password_length.present?
          I18n.t("devise.registrations.password_length_minimum_hint", count: @minimum_password_length)
        end
    end

    def role_params
      params.permit(system_role: { user: [] })[:system_role]
    end

    # List of supported roles prioritized by their privilege level
    def ordered_role_entries
      @ordered_role_entries ||= User::SUPPORTED_ROLES.entries.sort do |(_role_a, role_a_tuple), (_role_b, role_b_tuple)|
        role_b_tuple[0] <=> role_a_tuple[0]
      end
    end

    #
    # # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: %i[given_name family_name nickname])
    # end
    #
    # # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: %i[given_name family_name nickname])
    # end
    #
    # # The path used after sign up.
    # def after_sign_up_path_for(_resource)
    #   root_path
    # end
    #
    # # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(_resource)
    #   root_path
    # end
    #
    # # The path used after sign up for inactive accounts.
    # def after_update_path_for(_resource)
    #   root_path
    # end

    private

    def assign_default_role
      resource.add_role(:user) if resource.present? && resource_supports_roles? && resource.roles.blank?
    end

    def resource_supports_roles?
      resource_name.to_s.classify.constantize::SUPPORTED_ROLES.present?
    end
  end
end
