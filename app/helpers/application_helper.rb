# frozen_string_literal: true

module ApplicationHelper
  def page_title
    Rails.application.config.application_short_name ||
      Rails.application.class.module_parent_name
  end

  def crm_org_id
    AppUtils.crm_org_id
  end
end
