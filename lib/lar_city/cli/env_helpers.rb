# frozen_string_literal: true

require 'concerns/operating_system_detectable'
require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module EnvHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        base.extend ClassMethods
        base.include OperatingSystemDetectable

        # Throw an error unless included in a Thor class
        require_thor_ancestor!(base)

        # Throw an error unless included in a Thor class that supports options
        require_thor_options_support!(base)

        base.include InstanceMethods
      end

      module ClassMethods
        def define_env_options(thor_class, class_options: true)
          option_method = class_options ? :class_option : :option
          # Define Environment option
          thor_class
            .public_send(
              option_method,
              :environment,
              desc: 'Environment',
              type: :string,
              aliases: '--env',
              enum: %w[development test lab staging production],
              required: false
            )
        end

        # @deprecated This method is deprecated and will be removed in a future release.
        #   Use `define_sudo_option` from `ControlFlowHelpers` instead.
        def define_sudo_option(
          thor_class,
          desc: 'Run command with sudo (only applies to Unix-based systems)',
          class_option: false,
          default: false,
          required: false
        )
          option_method = class_option ? :class_option : :option
          thor_class.public_send(option_method, :sudo, type: :boolean, desc:, default:, required:)
        end
      end

      module InstanceMethods
        protected

        def detected_environment
          options[:environment] || Rails.env
        end

        # @deprecated This method is deprecated and will be removed in a future release.
        #   Use `sudo?` from `ControlFlowHelpers` instead.
        def sudo?
          options[:sudo] || false
        end
      end
    end
  end
end
