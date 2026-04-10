# frozen_string_literal: true

module Notion
  class Utils
    class << self
      def use_persist_event_workflow?
        Flipper.enabled?(:feat__notion_use_persist_event_workflow)
      end

      def skip_signature_validation?
        Flipper.enabled?(:feat__notion_webhook_skip_signature_validation)
      end
    end
  end
end
