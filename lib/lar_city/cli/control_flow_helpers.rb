# frozen_string_literal: true

require_relative 'utils/class_helpers'
require_relative 'output_helpers'

module LarCity
  module CLI
    module ControlFlowHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        require_thor_options_support!(base)

        base.extend ClassMethods
        base.include OutputHelpers
        base.include InstanceMethods
      end

      module ClassMethods
        def define_force_option(
          thor_class,
          desc: 'Force operation without confirmation prompt',
          class_option: false,
          default: false,
          long_desc: nil,
          required: false
        )
          option_method = class_option ? :class_option : :option
          thor_class
            .public_send(
              option_method, :force,
              type: :boolean,
              desc:, default:,
              long_desc:, required:
            )
        end

        def define_sudo_option(
          thor_class,
          desc: I18n.t('modules.control_flow_helpers.sudo_option.short_desc'),
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

        def confirm_execution(message = 'Are you sure you want to proceed?')
          return true if pretend? || dry_run?

          yes?(message)
        end

        def force?
          options[:force] == true
        end

        def sudo?
          options[:sudo] == true
        end
      end
    end
  end
end
