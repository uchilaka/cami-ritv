# frozen_string_literal: true

module Notion
  class VendorCreatedEvent < BaseEvent
    # See SO recommendation: https://stackoverflow.com/a/9463495/3726759
    def self.model_name
      GenericEvent.model_name
    end
  end
end
