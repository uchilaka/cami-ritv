# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class BlueprintCmd < BaseCmd
      no_commands do
        include EnvHelpers
        include ControlFlowHelpers
        include IntegrationHelpers
      end

      namespace 'blueprint'

      define_env_options(self, class_options: true)
      define_force_option(self, class_option: true, desc: 'Force an operation')

      class_option :platform,
                   desc: 'The target platform',
                   type: :string,
                   enum: %w[digitalocean render],
                   required: true,
                   default: 'digitalocean'

      desc 'check', I18n.t('commands.blueprint.check.short_desc')
      long_desc I18n.t('commands.blueprint.check.long_desc')
      def check
        send("check_#{options[:platform]}")
      end

      desc 'get', 'Get the active application blueprint'
      def get
        unless options[:platform] == 'digitalocean'
          raise NotImplementedError, not_implemented_error('blueprint:get')
        end
        require_doctl_cli!
        # yaml_template = File.read(Rails.root.join('config', 'app.yaml.erb').to_s)
        yaml_template = <<~TEMPLATE
          <%= shared_header %>
          <%= yaml_content %>
        TEMPLATE
        yaml_output = ERB.new(yaml_template).result(binding)
        status = pretend? ? 1 : File.write(output_file_path, yaml_output)
        if status.positive?
          say_success "Generated blueprint has been written to #{output_file_path}"
        else
          say_warning "Failed to write generated blueprint to #{output_file_path}"
        end
        say_debug yaml_output
      end

      desc 'setup', "Setup the application's blueprint configuration"
      def setup
        with_interruption_rescue do
          unless options[:platform] == 'digitalocean'
            raise NotImplementedError, not_implemented_error('blueprint:setup')
          end

          require_doctl_cli!
          unless File.exist?(template_path)
            raise ::LarCity::Errors::Unsupported, <<~ERROR
              Blueprint template not found at #{template_path}. This usually means the \
              #{detected_environment} environment is not configurable/supported/available \
              on #{options[:platform]} via this command.
            ERROR
          end

          yaml_template = File.read(template_path)
          yaml_output = ERB.new(yaml_template).result(binding)
          status = File.write(output_file_path, yaml_output)
          if status.positive?
            say_success "Generated blueprint has been written to #{output_file_path}"
          else
            say_warning "Failed to write generated blueprint to #{output_file_path}"
          end
          say_debug yaml_output
        end
      end

      desc 'update', I18n.t('commands.blueprint.update.short_desc')
      long_desc I18n.t('commands.blueprint.update.long_desc')
      def update
        with_interruption_rescue do
          unless options[:platform] == 'digitalocean'
            raise NotImplementedError, not_implemented_error('blueprint:update')
          end

          require_doctl_cli!
          setup if force? || !File.exist?(output_file_path)
          deploy_cmd = [
            'doctl apps update',
            DigitalOcean::Utils.app_id!,
            "--spec #{output_file_path}",
            "--access-token #{DigitalOcean::Utils.access_token!}",
            '--format ID,DefaultIngress,Created'
          ]
          deploy_cmd << '--verbose' if verbose?
          run(*deploy_cmd, eval: false) { |line| say_info line }
        end
      end

      no_commands do
        protected

        def check_render
          require_render_cli!

          blueprint_config = Rails.root.join('render.yaml').to_s
          run(
            'render blueprints validate',
            "--workspace #{ENV.fetch('RENDER_WORKSPACE_ID')}",
            blueprint_config
          ) { |line| say_info line }
        end

        def check_digitalocean
          access_token = DigitalOcean::Utils.access_token!
          setup if force? || !File.exist?(output_file_path)
          check_cmd = [
            'doctl apps spec validate',
            output_file_path,
            "--access-token #{access_token}"
          ]
          check_cmd << '--verbose' if verbose?
          result = run(*check_cmd, eval: false, inline: true)
          say_debug "Check command result: #{result}"
          if result == true
            say_success "Successfully validated blueprint: #{output_file_path}"
          else
            say_error "Failed to validate blueprint: #{output_file_path}"
            say_debug <<~DEBUG_MSG
              Validation failed for blueprint at #{output_file_path}. \
              Run this command for details on the validation errors:
              #{check_cmd.join(" ")}
            DEBUG_MSG
          end
        end

        def yaml_content
          app_id = DigitalOcean::Utils.app_id!
          access_token = DigitalOcean::Utils.access_token!
          codegen_cmd = ['doctl apps spec get', app_id, "--access-token #{access_token}", '--format yaml']
          codegen_cmd << '--verbose' if verbose?
          run(*codegen_cmd, eval: true)
        end
      end

      private

      def not_implemented_error(cmd)
        I18n.t('exceptions.integration_command_not_implemented', platform: options[:platform], cmd:)
      end

      def shared_header
        <<~HEADER
          # CONSIDER UPDATING THE TEMPLATE INSTEAD OF EDITING THIS FILE DIRECTLY.
          # It is generated from config/apps/#{detected_environment}.yaml.erb.
          #
          # You can also request the configured blueprint for this application by
          # running the `lx-cli blueprint:get` command.
          #
          # This file is used to configure the remote DigitalOcean application.
          # It is processed by ERB before being used, allowing you to include
          # dynamic content.
          # -------------------------------------------------------------------------
          # Automatically generated at #{Time.current.iso8601}
          # -------------------------------------------------------------------------
        HEADER
      end

      def output_file_path
        @output_file_path ||=
          if Rails.env.production?
            Rails.root.join('app.yaml').to_s
          else
            Rails.root.join("app.#{detected_environment}.yaml").to_s
          end
      end

      def template_path
        @template_path ||= Rails.root.join('config', 'apps', "#{detected_environment}.yaml.erb")
      end
    end
  end
end
