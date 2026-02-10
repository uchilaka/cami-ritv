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
        missing_ancestor_msg = <<~MSG
          #{base.name} is not a descendant of Thor or Thor::Group.
          #{name} can only be included in Thor or Thor::Group descendants.
        MSG
        raise missing_ancestor_msg unless has_thor_ancestor?(base)

        missing_options_method_msg = <<~MSG
          #{base.name} does not support options.
          #{name} can only be included in Thor classes that support options.
        MSG
        raise missing_options_method_msg unless supports_options?(base)

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

        def sudo?
          options[:sudo] || false
        end
      end
    end
  end
end
