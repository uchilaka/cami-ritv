# frozen_string_literal: true

module AutoSerializable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Serialization

    def serializable_hash(options = {})
      if (serializer_class = serializer_class_presence)
        serializer_class.new(self, options).serializable_hash.with_indifferent_access
      else
        super
      end
    end

    def compose
      serializable_hash.symbolize_keys
    end

    protected

    def serializer_class_presence(name_prefix: self.class.name)
      serializer_klass = self.class.serializer_klass if self.class.respond_to?(:serializer_klass)
      serializer_klass.presence || adhoc_serializer_class(name_prefix:)
    rescue NameError => _e
      false
    end

    def adhoc_serializer_class(name_prefix:)
      "#{name_prefix}Serializer".constantize
    end
  end
end
