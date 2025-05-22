# frozen_string_literal: true

module DynamicDomElementCapable
  extend ActiveSupport::Concern

  def anonymous_dom_id(seed_string)
    "#{slugify_for_dom(seed_string)}--#{SecureRandom.hex(4)}"
  end

  def slugify_for_dom(name)
    name.to_s.parameterize(separator: '-')
  end
end
