# frozen_string_literal: true

# @deprecated Dependent classes should use store_model gem for
#   serialization and deserialization of nested models.
#   See: https://github.com/DmitryTsepelev/store_model
#   This class is a placeholder for the future implementation of
#   nested model functionality.
class NestedModel
  include ActiveModel::API
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::Dirty

  # extend ActiveModel::Callbacks
  # extend ActiveModel::Validations::Callbacks

  attr_accessor :resource, :resource_attribute_name

  def initialize(args = {})
    super
    @resource_attribute_name ||= self.class.name.to_s.parameterize(separator: '_')
    @errors = ActiveModel::Errors.new(self)
  end

  define_model_callbacks :initialize, :save, :update, :validation

  def attributes
    {}
  end

  def save
    load do
      run_callbacks(:save) do
        resource.save if resource.respond_to?(:save)
      end
    end
  end

  def load
    if valid? && resource.present?
      resource.assign_attributes(resource_attribute_name => compose)
      yield if block_given?
    else
      false
    end
  end

  def compose
    serializable_hash.symbolize_keys
  end
end
