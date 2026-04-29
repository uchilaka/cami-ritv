# frozen_string_literal: true

require_relative 'base_cmd'
require 'json'
require 'yaml'

module LarCity
  module CLI
    class ImagesCmd < BaseCmd
      attr_reader :result

      namespace :images

      no_commands do
        include ServiceHelpers
      end

      desc 'build', I18n.t('commands.images.build.short_desc')
      long_desc I18n.t('commands.images.build.long_desc')
      add_service_option(
        desc: I18n.t('commands.images.build.options.service.short_desc'),
        long_desc: I18n.t('commands.images.build.options.service.long_desc'),
        required: true,
        type: :string
      )
      option :push, type: :boolean, default: false
      def build
        service_name = options[:service].to_s
        with_interruption_rescue do
          supported_services =
            docker_compose_config["services"].entries.select do |_name, config|
              config.key?("build")
            end.to_h
          say_debug <<~SUPPORTED_SERVICES
            The following services are available:
            #{YAML.dump(supported_services)}
          SUPPORTED_SERVICES
          names_of_supported_services = supported_services.keys
          say_debug YAML.dump(docker_compose_config.dig(:services, service_name))
          unless has_build_config? service_name
            raise Errors::Unsupported,
                  I18n.t(
                    'commands.images.build.unsupported_service_message',
                    list_of_names: names_of_supported_services,
                    compose_file: docker_compose_config_file,
                    name: service_name
                  )
          end
        end
        cmd_args = ['docker compose build', service_name]
        cmd_args << "--dry-run" if pretend?
        cmd_args << "--push" if options[:push]
        @result =
          run(
            *cmd_args,
            always_run: true, eval: true,
            mock_return: "Image #{service_name} Built"
          ) { |line| say_info(line) }
        say_debug "Build result: #{result.inspect}"
        unless success?
          say_error I18n.t('commands.images.build.failure_message', name: service_name, error_details: "TBD")
          return
        end

        # TODO: Extract image_id from this content pattern: naming to registry.fly.io/cami-lab-worker:latest
        say_success I18n.t('commands.images.build.success_message', name: service_name, image_id: "TBD")
      end

      private

      def success?
        return true if result.is_a?(Process::Status) && result.success?

        # TODO: Make this regex test case-insensitive while using %r
        %r{Image #{options[:service]} Built}.match?(result)
      end

      def has_build_config?(name)
        (docker_compose_config.dig("services", name) || {}).key?("build")
      end
    end
  end
end
