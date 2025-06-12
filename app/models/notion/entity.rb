# frozen_string_literal: true

module Notion
  class Entity < ::LarCity::AbstractModel
    attribute :id, :string
    attribute :type, :string, default: 'generic'

    def initialize(args = {})
      super
    end

    def attributes
      {}
    end
  end
end
