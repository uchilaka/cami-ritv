# frozen_string_literal: true

class CustomExceptionsAppWrapper
  def initialize(exceptions_app: nil)
    @exceptions_app =
      if exceptions_app.blank?
        ErrorsController.action(:show)
      else
        exceptions_app
      end
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    fallback_to_html_format_if_invalid_mime_type(request)

    @exceptions_app.call(env)
  end

  private

  def fallback_to_html_format_if_invalid_mime_type(request)
    request.formats
  rescue ActionDispatch::Http::MimeNegotiation::InvalidType
    request.set_header 'CONTENT_TYPE', 'text/html'
  end
end
