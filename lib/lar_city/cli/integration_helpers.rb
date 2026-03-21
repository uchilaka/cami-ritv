# frozen_string_literal: true

require_relative 'utils/class_helpers'
require_relative 'output_helpers'

module LarCity
  module CLI
    module IntegrationHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        require_thor_options_support!(base)

        base.include OutputHelpers
        base.include Runnable
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        def require_render_cli!
          return if run('which render > /dev/null 2>&1', mock_return: true, inline: true)

          say_warning <<~MSG.squish
            ⚠️ The 'render' CLI tool is not installed or not found in the system PATH.
            Please install the Render CLI to use this command. You can install it via
            Brew by running 'brew install render' or by following the instructions at
            https://render.com/docs/cli#setup.
          MSG
          raise Thor::Error, 'Render CLI is required but not found in PATH.'
        end

        def require_doctl_cli!
          return if run('which doctl > /dev/null 2>&1', mock_return: true, inline: true)

          say_warning <<~MSG.squish
            The 'doctl' CLI tool is not installed or not found in the system PATH.
            Please install the DigitalOcean CLI to use this command. You can install it via
            Brew by running 'brew install doctl' or by following the instructions at
            https://docs.digitalocean.com/reference/doctl/how-to/install/.
          MSG
          raise Thor::Error, 'DigitalOcean CLI (doctl) is required but not found in PATH.'
        end
      end
    end
  end
end
