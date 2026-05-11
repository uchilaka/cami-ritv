# frozen_string_literal: true

require_relative 'utils/class_helpers'
require_relative 'output_helpers'
require 'yaml'

module LarCity
  module CLI
    module ServiceHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        require_thor_options_support!(base)

        # Class methods must be extended FIRST, before applying delegations
        base.extend ClassMethods
        delegate :docker_compose_config, to: base
        delegate :docker_compose_config_file, to: base

        base.include OutputHelpers
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        # def docker_compose_config(symbolize_names: false)
        #   @docker_compose_config ||= YAML.load(File.read(docker_compose_config_file), symbolize_names:)
        # end
        #
        # def docker_compose_config_file
        #   Rails.root.join('docker-compose.yml').to_s
        # end
      end

      module ClassMethods
        def add_service_option(
          desc:,
          type: :array,
          enum: %w[web app-store worker mailhog tunnel].sort,
          long_desc: nil,
          required: false
        )
          option(:service, aliases: '-s', enum:, type:, desc:, long_desc:, required:)
        end

        def docker_compose_config(symbolize_names: false)
          @docker_compose_config ||= YAML.load(File.read(docker_compose_config_file), symbolize_names:)
        end

        def docker_compose_config_file
          Rails.root.join('docker-compose.yml').to_s
        end
      end
    end
  end
end
