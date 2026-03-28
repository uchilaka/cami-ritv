# frozen_string_literal: true

require 'concerns/operating_system_detectable'
require_relative 'env_helpers'
require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module VaultHelpers
      extend Utils::ClassHelpers
      VaultSourceItem = Struct.new(:id, :name, keyword_init: true)

      def self.included(base)
        base.include EnvHelpers
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

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

        def vault_share_id
          vault_credentials.vault_share_id
        end

        def vault_source_items
          @vault_sources ||= {
            shared:
              VaultSourceItem
                .new(
                  id: vault_credentials.shared_env_vars_item_id,
                  name: 'Environment variables (shared)'
                ),
            detected_environment =>
              VaultSourceItem
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
