# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def serializable_hash(options = {})
    if (serializer_class = serializer_class_presence)
      serializer_class.new(self, options).serializable_hash.with_indifferent_access
    else
      super
    end
  end

  protected

  def serializer_class_presence(name_prefix: self.class.name)
    adhoc_serializer_class(name_prefix:)
  rescue NameError
    false
  end

  def adhoc_serializer_class(name_prefix:)
    "#{name_prefix}Serializer".constantize
  end
end
