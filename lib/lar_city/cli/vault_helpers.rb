# frozen_string_literal: true

require 'json'
require 'concerns/operating_system_detectable'
require_relative 'control_flow_helpers'
require_relative 'env_helpers'
require_relative 'output_helpers'
require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module VaultHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        base.extend ClassMethods
        base.include ControlFlowHelpers
        base.include EnvHelpers
        base.include OutputHelpers
        base.include InstanceMethods
      end

      module ClassMethods
        def define_vault_store_option(
          thor_class,
          name:,
          default: nil,
          class_option: false,
          desc: "A vault store as a source or destination of secrets",
          required: true,
          enum: %w[development lab production fly.io digitalocean]
        )
          option_method = class_option ? :class_option : :option
          thor_class
            .public_send(
              option_method,
              name.to_sym,
              type: :string,
              default:, desc:, enum:, required:,
            )
        end
      end

      module InstanceMethods
        protected

        def env_content_from_source_item_data(structured: false)
          require_authenticated_vault_connection!

          result = run(
            'pass-cli item view',
            '--output=json',
            "--item-id=#{source_item_id}",
            "--share-id=#{vault_share_id}",
            always_run: true,
            eval: true
          )
          json_data = JSON.parse(result)
          say_debug JSON.pretty_generate(json_data)
          params_by_section = {}
          erb_template_array = []
          json_data.dig('item', 'content', 'content', 'Custom', 'sections').each do |section|
            section_name, fields = section.values_at 'section_name', 'section_fields'
            section_slug = paramify(section_name)
            section_header = "#{'#' * 24} #{section_name} (#{detected_environment}) #{'#' * 24}"
            params = []
            erb_template_array << section_header
            # The prefix should ALWAYS be a plain text field, never hidden
            prefix = (fields.find { |f| paramify(f['name']) == 'prefix' } || {}).dig('content', 'Text')
            say_debug <<~SECTION_INFO
              |-----------------Section-------------------
              | Name:     #{section_name}
              | Slug:     #{section_slug}
              | Tally:    #{tally(fields, 'field')}
              | Prefix:   #{(prefix.presence || '<None>').strip}
            SECTION_INFO
            fields.each do |field|
              name, content = field.values_at 'name', 'content'
              value = content['Text'] || content['Hidden']
              next if value.blank? || paramify(name) == 'prefix'

              var_name = envify(prefix, name)
              # Skip setting the Rails master key if it has already been set for
              # the detected environment
              if var_name == 'RAILS_MASTER_KEY' && ENV.key?(var_name)
                say_warning <<~WARNING
                  RAILS_MASTER_KEY was detected in the environment and will be skipped.
                  If you need to update the value, please update it directly in your environment
                  and ensure it is not being fetched from Proton Vault to avoid potential issues
                  with Rails encrypted credentials.
                WARNING
                next
              end

              if var_name == 'HOSTNAME' && ENV.key?(var_name)
                say_warning <<~WARNING
                  HOSTNAME was detected in the environment and will be skipped.
                  If you need to update the value, please update it directly in your environment
                  and ensure it is not being fetched from Proton Vault to avoid potential issues
                  with server configuration and connectivity.
                WARNING
                next
              end

              # Compose variable export content row for provisioning environments with .tpl files
              erb_template_array << "export #{var_name}=\"#{value}\""
              # Configure params as name, value tuple
              params << [var_name, value]
            end
            erb_template_array << "\n"
            params_by_section[section_slug] = { header: section_header, params: }
          end
          say_debug JSON.pretty_generate(params_by_section)
          return params_by_section if structured

          erb_template_array.join("\n")
        rescue JSON::ParserError => e
          say_error e.message
          nil
        end

        def require_vault_cli!
          return if run('which pass-cli > /dev/null 2>&1', mock_return: true, eval: false, inline: true)

          say_error 'Proton CLI (pass-cli) is not installed or not found in PATH. Please install it to fetch secrets from Proton Vault.'
          raise Thor::Error, 'Proton CLI (pass-cli) is required but not found in PATH.'
        end

        def require_authenticated_vault_connection!
          require_vault_cli!
          result = run('pass-cli test', eval: true)
          say_debug "[pass-cli test] result: #{result.inspect}"
          return if %r{Connection successful}.match?(result)

          say_error 'Unable to authenticate with Proton Vault. Please ensure you are logged in and have access to the vault share.'
          raise Thor::Error, 'Authentication with Proton Vault failed.'
        end

        def source_item_id
          @source_item_id ||=
            ENV.fetch(
              'ENV_VARS_ITEM_ID',
              vault_source_items[detected_environment].id
            )
        end

        def shared_source_item_id
          vault_source_items[:shared].id
        end

        def vault_share_id
          vault_credentials.vault_share_id
        end

        def vault_source_items
          @vault_sources ||= {
            shared:
              ::Struct::VaultSourceItem
                .new(
                  id: vault_credentials.shared_env_vars_item_id,
                  name: 'Environment variables (shared)'
                ),
            detected_environment =>
              ::Struct::VaultSourceItem
                .new(
                  id: vault_credentials.env_vars_item_id,
                  name: "Environment variables (#{detected_environment})"
                ),
          }
        end

        def vault_credentials
          @vault_credentials ||= Rails.application.credentials.proton!
        end
      end
    end
  end
end
