# frozen_string_literal: true

module AutoSerializable
  extend ActiveSupport::Concern

  included do
    @serializer_klass = nil

    class_eval do
      include ClassMethods
    end

    include ActiveModel::Serialization
    include InstanceMethods
  end

  module InstanceMethods
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

    # Check for explicitly set serializer class or try to find one based on naming convention.
    def serializer_class_presence(name_prefix: self.class.name)
      serializer_klass = self.class.serializer_klass if self.class.respond_to?(:serializer_klass)
      serializer_klass.presence || adhoc_serializer_class(name_prefix:)
    rescue NameError => _e
      false
    end

    # This is where the "auto-serialization" magic happens.
    # It supports finding a serializer class based on naming convention.
    def adhoc_serializer_class(name_prefix:)
      "#{name_prefix}Serializer".constantize
    end
  end

  module ClassMethods
    def set_serializer_klass(klass)
      @serializer_klass = klass
    end

    def serializer_klass
      @serializer_klass ||= "#{name}Serializer".constantize
    end
  end
end
