# frozen_string_literal: true

module LarCity
  class AbstractModel
    # https://guides.rubyonrails.org/v8.0/active_model_basics.html#attributes
    include ActiveModel::Model
    # include ActiveModel::Conversion
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include AutoSerializable

    # https://guides.rubyonrails.org/v8.0/active_model_basics.html#callbacks
    # extend ActiveModel::Callbacks
    # extend ActiveModel::Validations::Callbacks

    def attributes
      raise NotImplementedError, "#{self.class} must implement the attributes method"
    end
  end
end
