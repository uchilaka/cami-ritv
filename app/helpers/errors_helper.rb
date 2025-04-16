# frozen_string_literal: true

module ErrorsHelper
  def page_title
    case response.status
    when 404
      'Page Not Found'
    when 403
      'Forbidden'
    when 500
      'Internal Server Error'
    else
      Rails.application.class.module_parent_name
    end
  end

  def cta_resource_url
    @cta_resource_url ||= root_path
  end

  def cta_label
    @cta_label ||= t('ctas.main.return_home')
  end
end
