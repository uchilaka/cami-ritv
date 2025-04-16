# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'error'

  # TODO: How does this impact analytics? E.g. reporting to tools like Heap that the
  #   customer experienced an error?
  protect_from_forgery with: :exception

  # skip_before_action :authenticate_user!

  rescue_from LarCity::Errors::ElevatedPrivilegesRequired, with: :forbidden
  rescue_from LarCity::Errors::UnprocessableEntity, with: :unprocessable_entity
  rescue_from LarCity::Errors::InternalServerError, with: :server_error
  rescue_from LarCity::Errors::ResourceNotFound, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity
  rescue_from ActionController::RoutingError do |exception|
    emit_routing_exception(exception)
  end

  def show
    @exception = request.env['action_dispatch.exception']
    @status_code =
      @exception.try(:status_code) ||
      ActionDispatch::ExceptionWrapper.new(request.env, @exception).status_code

    render view_for_code(@status_code), status: @status_code
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

  def render_static_error
    error_view, code = resolve_status
    render error_view, status: code
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
