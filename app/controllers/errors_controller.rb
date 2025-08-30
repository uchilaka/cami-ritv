# frozen_string_literal: true

class ErrorsController < ApplicationController
  attr_reader :exception, :error_status_code

  layout 'error'

  # TODO: How does this impact analytics? E.g. reporting to tools like Heap that the
  #   customer experienced an error?
  protect_from_forgery with: :exception

  skip_before_action :authenticate_user!

  before_action :set_error_status_code

  rescue_from LarCity::Errors::ElevatedPrivilegesRequired, with: :forbidden
  rescue_from LarCity::Errors::UnprocessableEntity, with: :unprocessable_entity
  rescue_from LarCity::Errors::InternalServerError, with: :server_error
  rescue_from LarCity::Errors::ResourceNotFound, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from ActionController::RoutingError do |exception|
    if Flipper.enabled?(:feat__replay_routing_errors)
      emit_routing_exception(exception)
    else
      handle_routing_error
    end
  end

  def show
    render view_for_code(error_status_code), status: error_status_code
  end

  def unprocessable_entity
    render 'errors/unprocessable_entity', status: :unprocessable_entity
  end

  def not_found
    render 'errors/not_found', status: :not_found
  end

  def forbidden
    render 'errors/forbidden', status: :forbidden
  end

  def server_error
    render 'errors/server_error', status: :internal_server_error
  end

  def emit_routing_exception(_exception = nil)
    @mutex ||= Mutex.new
    @mutex.synchronize do
      if %r{/admin/}.match?(request.fullpath)
        raise LarCity::Errors::ElevatedPrivilegesRequired if request.params[:unmatched].present?

        raise LarCity::Errors::UnprocessableEntity
      end

      raise LarCity::Errors::ResourceNotFound
    end
  end

  def handle_routing_error
    @mutex ||= Mutex.new
    @mutex.synchronize do
      if %r{/admin/}.match?(request.fullpath)
        if request.params[:unmatched].present?
          render view_for_code(403), status: :forbidden
        else
          render view_for_code(422), status: :unprocessable_entity
        end
      else
        render view_for_code(error_status_code), status: error_status_code
      end
    end
  end

  def status_code_from_exception
    @exception = request.env['action_dispatch.exception']
    @exception.try(:status_code) ||
      ActionDispatch::ExceptionWrapper.new(request.env, @exception).status_code
  end

  def render_static_error
    error_view, code = resolve_status
    render error_view, status: code
  end

  protected

  # Also sets :exception
  def set_error_status_code
    @error_status_code = status_code_from_exception
  end

  private

  def resolve_status(observed_status_code = nil)
    observed_status_code ||= params[:code].to_i
    supported_codes = supported_error_codes.keys
    resolved_code = supported_codes.include?(observed_status_code) ? observed_status_code : 404
    [view_for_code(resolved_code), resolved_code]
  end

  def view_for_code(code)
    supported_error_codes.fetch(code, '404')
  end

  def supported_error_codes
    {
      403 => 'errors/forbidden',
      404 => 'errors/not_found',
      500 => 'errors/server_error'
    }.with_indifferent_access
  end
end
