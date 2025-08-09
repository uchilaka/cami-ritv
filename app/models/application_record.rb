# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include AutoSerializable
  include Pagination

  primary_abstract_class

  def short_sha
    Digest::SHA256.hexdigest(serializable_hash.sort.to_s).first(8)
  end

  def id_first_5
    id_prefix(5)
  end

  def id_last_5
    id_suffix(5)
  end

  protected

  def id_prefix(slice_length = 4)
    return nil if id.blank?

    id.slice(0, slice_length)
  end

  def id_suffix(slice_length = 4)
    return nil if id.blank?

    id.slice(-slice_length, slice_length)
  end

  def crm_resource_url(uri = nil)
    ["https://crm.zoho.com/crm/org#{crm_org_id}", uri].compact.join('/')
  end

  def crm_org_id
    Rails.application.credentials&.zoho&.org_id
  end
end
