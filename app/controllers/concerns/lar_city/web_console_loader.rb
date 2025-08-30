# frozen_string_literal: true

module LarCity
  module WebConsoleLoader
    extend ActiveSupport::Concern
    module ClassMethods
      def load_console(*actions, options: {})
        actions += supported_actions if actions.blank?
        [*actions].flatten.each { |action| authorized_actions[action] = options }

        before_action :initialize_web_console, only: authorized_actions.keys
      end

      def authorized_actions
        @authorized_actions ||= {}.with_indifferent_access
      end

      def supported_actions
        %i[index new show edit]
      end
    end

    def initialize_web_console
      return if Rails.env.test? || Rails.env.staging? || Rails.env.production?

      console if current_user&.admin? || Rails.env.development?
    end
  end
end
