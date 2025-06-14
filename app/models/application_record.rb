# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_action :set_paper_trail_whodunnit

  def serializable_hash(options = {})
    if (serializer_class = serializer_class_presence)
      serializer_class.new(self, options).serializable_hash.with_indifferent_access
    else
      super
    end
  end

  protected

  def crm_resource_url(uri = nil)
    ["https://crm.zoho.com/crm/org#{crm_org_id}", uri].compact.join('/')
  end

  def crm_org_id
    Rails.application.credentials&.zoho&.org_id
  end

  def serializer_class_presence(name_prefix: self.class.name)
    adhoc_serializer_class(name_prefix:)
  rescue NameError
    false
  end

  def adhoc_serializer_class(name_prefix:)
    "#{name_prefix}Serializer".constantize
  end
end
