# frozen_string_literal: true

module Renderable
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
    include InstanceMethods
  end

  module ClassMethods
    def modal_dom_id(resource:, content_type: nil)
      return "#{resource.model_name.singular}--#{content_type}--modal|#{resource.id}|" unless content_type.blank?

      "#{resource.model_name.singular}--modal|#{resource.id}|"
    end
  end

  module InstanceMethods
    def modal_dom_id(content_type: nil)
      raise ArgumentError, 'Resource must be an ActiveRecord::Base object' \
        unless self.class.ancestors.include?(ActiveRecord::Base)

      self.class.modal_dom_id(resource: self, content_type:)
    end
  end
end
