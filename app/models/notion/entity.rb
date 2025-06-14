# frozen_string_literal: true

module Notion
  class Entity < ::LarCity::AbstractModel
    attribute :id, :string
    attribute :type, :string

    define_callbacks :initialize, :validation

    attr_accessor :data

    def self.supported_types
      %w[page database person]
    end

    def supported_types
      self.class.supported_types
    end

    validates :type, presence: true, inclusion: { in: lambda(&:supported_types) }

    def attributes
      { id:, type: }
    end

    def initialize(args = {})
      super
      @data = (args[:data] || {}).to_h.deep_symbolize_keys
      # clear_attribute_changes(attributes.keys)

      attributes.each_key do |k|
        attr_value = args[k] || @data[k]
        next if deserializable_attributes.include?(k)
        next unless attr_value.present?

        # instance_variable_set("@#{k}", attr_value)
        send("#{k}=", attr_value)
      end

      # define_model_callbacks :initialize, :validation

      # self.id ||= args.dig(:data, :id)
      # self.type ||= args[:type] || @data[:type]
      # self.type ||= @data[:type]
      @errors = ActiveModel::Errors.new(self)
    end

    def deserializable_attributes
      []
    end
  end
end
