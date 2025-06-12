# frozen_string_literal: true

module Notion
  class Event < ::LarCity::AbstractModel
    def initialize(args = {})
      super
      @id ||= SecureRandom.uuid
      @timestamp ||= Time.current
      @workspace_id ||= args[:workspace_id]
      @workspace_name ||= args[:workspace_name]
      @type = args[:type] || 'generic'
      @entity = args[:entity] || {}
      @parent = args.dig(:data, :parent) || {}
      @authors = args[:authors] || []
      @errors = ActiveModel::Errors.new(self)
    end

    define_model_callbacks :initialize, :validation

    def attributes
      {}
    end

    def compose
      serializable_hash.symbolize_keys
    end
  end
end
