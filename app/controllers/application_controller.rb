# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # include LarCity::CurrentAttributes
  # include LarCity::WebConsoleLoader
  include Pundit::Authorization

  # before_action :set_paper_trail_whodunnit

  # For more on action controller filters, see https://guides.rubyonrails.org/action_controller_overview.html#filters
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :public_resource?

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'legacy-application'

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :name, :email, :password)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:first_name, :last_name, :name, :email, :password, :password_confirmation, :current_password)
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  protected

  def public_resource?
    public_page? || demo_page? || %w[/up /api/features].include?(request.path)
  end

  def demo_page?
    %r{^/demos(/)?}.match?(request.path)
  end

  def public_page?
    params['controller'] == 'pages' &&
      params['action'] == 'app' &&
      (params['path'].nil? || public_app_paths.include?(params['path']))
  end

  def public_app_paths
    %w[
      about
      home
      legal/terms
      legal/privacy
    ]
  end
end
