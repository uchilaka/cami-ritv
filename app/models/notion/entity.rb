# frozen_string_literal: true

module Notion
  class Entity < ::LarCity::AbstractModel
    attribute :id, :string
    attribute :type, :string

    attr_accessor :data

    # Class methods
    def self.supported_types
      %w[page database user].freeze
    end

    validates :type, presence: true, inclusion: { in: supported_types }

    def initialize(args = {})
      super
      args.deep_symbolize_keys!
      @data = args[:data] || {}

      attributes.each_key do |k|
        attr_value = args[k] || @data[k]
        next if deserializable_attributes.include?(k)
        next unless attr_value.present?

        # case k
        # when :entity
        #   deserialize_entity(attr_value)
        # when :parent
        #   deserialize_parent(attr_value)
        # else
        #   instance_variable_set(:"@#{k}", attr_value)
        # end
        instance_variable_set(:"@#{k}", attr_value)
      end

      # self.id ||= args.dig(:data, :id)
      # self.type ||= args[:type] || @data[:type]
      # self.type ||= @data[:type]
      @errors = ActiveModel::Errors.new(self)
    end

    def attributes
      { id:, type: }
    end

    def deserializable_attributes
      []
    end
  end
end
