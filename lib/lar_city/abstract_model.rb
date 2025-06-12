# frozen_string_literal: true

module LarCity
  class AbstractModel
    include ActiveModel::API
    include ActiveModel::Serialization
    include AutoSerializable
    extend ActiveModel::Callbacks
    extend ActiveModel::Validations::Callbacks

    def attributes
      raise NotImplementedError, "#{self.class} must implement the attributes method"
    end
  end
end
