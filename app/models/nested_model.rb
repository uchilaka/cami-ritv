# frozen_string_literal: true

class NestedModel
  include ActiveModel::API
  include ActiveModel::Serialization
  extend ActiveModel::Callbacks
  extend ActiveModel::Validations::Callbacks
  include ActiveModel::Dirty

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
