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
        delegate :compose_config_file, to: base

        base.include OutputHelpers
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

        def compose_config(with_override: false)
          if with_override
            return (compose_base_config || {})
                     .deep_merge(compose_override_config || {})
          end

          compose_base_config
        end

        alias :docker_compose_config :compose_config

        def compose_base_config
          @compose_base_config ||=
            YAML.load(File.read(compose_config_file), symbolize_names: false)
        end

        def compose_override_config
          @compose_override_config ||=
            YAML.load(File.read(compose_override_config_file), symbolize_names: false)
        end

        def compose_config_file
          @compose_config_file ||= %w[compose.yml docker-compose.yml].find do |basename|
            Rails.root.join(basename).exist?
          end
        ensure
          @compose_config_file ||= Rails.root.join('docker-compose.yml').to_s
        end

        def compose_override_config_file
          @compose_override_config_file ||=
            %w[compose.override.yml docker-compose.override.yml].find do |basename|
              Rails.root.join(basename).exist?
            end
        ensure
          @compose_override_config_file ||= Rails.root.join('docker-compose.override.yml').to_s
        end
      end
    end
  end
end
