# frozen_string_literal: true

module Notion
  class Event < ::LarCity::AbstractModel
    attribute :id, :string
    attribute :timestamp, :datetime
    attribute :workspace_id, :string
    attribute :workspace_name, :string
    attribute :subscription_id, :string
    attribute :integration_id, :string
    attribute :attempt_number, :integer, default: 1
    attribute :type, :string
    attribute :entity, :hash, default: {}
    attribute :data, :hash, default: {}

    def initialize(args = {})
      super
      # @id ||= SecureRandom.uuid
      @timestamp ||= Time.current
      # @workspace_id ||= args[:workspace_id]
      # @workspace_name ||= args[:workspace_name]
      @type = args[:type] || 'generic'
      @entity = Entity.new(args[:entity]) unless args[:entity].nil?
      @data = args[:data] || {}
      # @parent = args.dig(:data, :parent) || {}
      # @authors = args[:authors] || []
      @errors = ActiveModel::Errors.new(self)
    end

    define_model_callbacks :initialize, :validation

    def attributes
      {}
    end

    def parent
      @parent ||=
        if @data.dig(:parent, :type) == 'database'
          Notion::Database.new(@data[:parent])
        elsif @data.dig(:parent, :type) == 'page'
          Notion::Page.new(@data[:parent])
        end
    end

    def authors
      @authors ||=
        if @data[:authors].present?
          @data[:authors].map do |author|
            Notion::Entity.new(author)
          end
        else
          []
        end
    end

    def compose
      serializable_hash.symbolize_keys
    end
  end
end
