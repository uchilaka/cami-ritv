# frozen_string_literal: true

module ApplicationHelper
  include StyleHelper

  def anonymous_dom_id(seed_string)
    "#{slugify_for_dom(seed_string)}--#{SecureRandom.hex(4)}"
  end

  def slugify_for_dom(name)
    name.to_s.parameterize(separator: '-')
  end

  def modal_dom_id(resource, content_type: nil)
    raise ArgumentError, "#{resource.class.name} MUST be Renderable" \
      unless resource.respond_to?(:modal_dom_id)

    resource.modal_dom_id(content_type:)
  end

  def record_dom_id(resource, prefix: '')
    dom_id = "#{resource.model_name.singular}-row-#{resource.id}"
    if prefix.present?
      "#{prefix}--#{dom_id}"
    else
      dom_id
    end
  end

  def omniauth_authorize_path(_resource_name, _provider)
    user_google_omniauth_authorize_path
  end

  def page_title
    Rails.application.config.application_short_name ||
      Rails.application.class.module_parent_name
  end

  def crm_org_id
    AppUtils.crm_org_id
  end
end
