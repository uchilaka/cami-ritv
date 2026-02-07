# frozen_string_literal: true

module Notion
  class Event < Entity
    set_serializer_klass Notion::RemoteEventSerializer

    attribute :timestamp, :datetime
    attribute :workspace_id, :string
    attribute :workspace_name, :string
    attribute :subscription_id, :string
    attribute :integration_id, :string
    attribute :attempt_number, :integer, default: 1

    attr_accessor :entity, :parent, :authors

    def self.supported_types
      %w[
        database.content_updated
        database.deleted
        database.schema_updated
        page.created
        page.content_updated
        page.deleted
        page.moved
        page.properties_updated
      ]
    end

    validates :data, presence: true

    def attributes
      {
        id:,
        type:,
        timestamp:,
        workspace_name:,
        attempt_number:,
        workspace_id:,
        subscription_id:,
        integration_id:,
      }
    end

    def deserializable_attributes
      %w[entity parent authors]
    end

    def initialize(args = {})
      super
      self.timestamp ||= Time.current
      @entity = deserialize_entity(@entity || @data[:entity])
      # Try fetching the parent assuming the webhook request params data signature
      @parent = deserialize_parent(@parent || @data.dig(:data, :parent))
      # TODO: Attempt a default deserialization of parent if missed in prior dig
      #   Is there a way to avoid this two-step deserialization for the parent data?
      @parent ||= deserialize_parent
      # Try authors
      @authors = deserialize_authors(@authors || @data[:authors])
      @authors ||= []
    end

    # define_model_callbacks :initialize, :validation

    # def authors
    #   @authors ||=
    #     if @data[:authors].present?
    #       @data[:authors].map do |author|
    #         Notion::Entity.new(author)
    #       end
    #     else
    #       []
    #     end
    # end

    def compose
      serializable_hash.symbolize_keys
    end

    private

    def deserialize_authors(authors_data = @data[:authors])
      return unless authors_data.present?
      return unless authors_data.is_a?(Array)
      return authors_data if authors_data.all? { |a| a.is_a?(Notion::Entity) }

      authors_data.map do |author|
        if author.is_a?(Notion::Entity)
          author
        else
          Notion::Entity.new(author)
        end
      end
    end

    def deserialize_parent(parent_data = @data[:parent])
      return unless parent_data.present?
      return parent_data if parent_data.is_a?(Notion::Entity)

      deserialize_entity(parent_data)
    end

    def deserialize_entity(entity_data)
      return unless entity_data.present?
      return entity_data if entity_data.is_a?(Notion::Entity)

      case entity_data[:type]
      when 'database'
        Notion::Database.new(entity_data)
      when 'page'
        Notion::Page.new(entity_data)
      else
        Notion::Entity.new(entity_data)
      end
    end
  end
end
