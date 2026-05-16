# frozen_string_literal: true

require_relative 'base_cmd'
require 'json'
require 'yaml'

module LarCity
  module CLI
    class ImagesCmd < BaseCmd
      attr_reader :result, :tag_result, :registry_auth_result, :push_result

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
        check_required_env_vars!
        service_name = options[:service].to_s
        with_interruption_rescue do
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
        cmd_args << '--dry-run' if pretend?
        cmd_args << '--push' if options[:push]
        @result =
          run(
            *cmd_args,
            always_run: true, eval: true,
            mock_return: "Image #{service_name} Built"
          ) { |line| say_info(line) }
        say_debug "Build result: #{result.inspect}"
        unless success?
          say_error I18n.t('commands.images.build.failure_message', name: service_name, error_details: 'TBD')
          return
        end
        say_success I18n.t('commands.images.build.success_message', name: service_name, image_id: container_name)

        version = 'latest'
        @tag_result =
          run 'docker tag',
              [container_name, version].join(':'),
              [container_tag, version].join(':'),
              mode: 'inline_with_result',
              mock_return: true
        say_debug "Re-tag result: #{tag_result.inspect}"

        unless tag_result
          say_error(
            I18n.t(
              'commands.images.build.tag_failure_message',
              name: service_name, tag: container_tag, error_detail: 'TBD'
            )
          )
          return
        end

        say_success(
          I18n.t('commands.images.build.tag_success_message', name: service_name, new_tag: container_tag)
        )
        return unless options[:push]

        # TODO: Extract image_id from this content pattern: naming to registry.fly.io/cami-lab-worker:latest
        check_registry_image_tag!
        @registry_auth_result = run('fly auth docker', eval: true, always_run: true)
        say_debug("Registry login result: #{registry_auth_result.inspect}")
        unless %r{^Authentication successful}.match?(registry_auth_result)
          say_error(
            I18n.t(
              'commands.images.build.registry_login_failure_message',
              registry: ENV.fetch('CONTAINER_REGISTRY_HOST'),
              error_details: 'TBD'
            )
          )
          return
        end

        @push_result =
          run('docker push', "#{container_tag}:#{version}", eval: true) do |progress|
            say_debug progress
          end
        say_debug("Push result: #{push_result.inspect}")
      end

      no_commands do
        def check_registry_image_tag!
          registry_host, image_name, version_tag =
            %r{(.*)\/(.*)(?::(.*))?}.match(container_tag).values_at(1, 2, 3)
          say_debug "Tag match data: #{{ registry_host:, image_name:, version_tag: }.inspect}"
          unless registry_host.present? && image_name.present?
            raise Thor::Error, <<~MSG
              The generated registry image tag '#{container_tag}' does not match the \
              expected format 'registry-host/image-name:version-tag'.
            MSG
          end
        end

        def check_required_env_vars!
          missing_required_vars = []
          %w[CONTAINER_REGISTRY_HOST CONTAINER_NAME_PREFIX].each do |var|
            missing_required_vars << var if ENV[var].blank?
          end
          return if missing_required_vars.none?

          raise Thor::Error, <<~MSG
          The following required environment variables are missing: #{missing_required_vars.inspect}.
        MSG
        end

        def container_tag(service: options[:service])
          raise ArgumentError, '--service is required' if service.blank?

          unless supported_services.key?(service)
            raise Errors::Unsupported,
                  I18n.t(
                    'commands.images.build.unsupported_service_message',
                    list_of_names: supported_services.keys,
                    compose_file: docker_compose_config_file,
                    name: service
                  )
          end

          Rails.application.config_for('container-registry').dig(:aliases, service.to_sym)
        end

        def container_name(service: options[:service])
          raise ArgumentError, '--service is required' if service.blank?

          unless supported_services.key?(service)
            raise Errors::Unsupported,
                  I18n.t(
                    'commands.images.build.unsupported_service_message',
                    list_of_names: supported_services.keys,
                    compose_file: docker_compose_config_file,
                    name: service
                  )
          end

          # Build the base image name
          image_name = [ENV.fetch('CONTAINER_NAME_PREFIX'), service].compact.join('-')
          # Prepend a namespace or registry hostname
          [ENV.fetch('CONTAINER_REGISTRY_HOST'), image_name].compact.join('/')
        end

        def supported_services
          @supported_services ||=
            docker_compose_config(with_override: true)['services'].entries.select do |_name, config|
              config.key?('build')
            end.to_h
        end

        def success?
          return true if result.is_a?(Process::Status) && result.success?

          # TODO: Make this regex test case-insensitive while using %r
          %r{Image (.*) Built}.match?(result)
        end

        def has_build_config?(name)
          (docker_compose_config.dig('services', name) || {}).key?('build')
        end
      end
    end
  end
end
