# frozen_string_literal: true

require 'concerns/operating_system_detectable'
require_relative 'env_helpers'
require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module VaultHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        base.include EnvHelpers
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        def require_vault_cli!
          return if run('which pass-cli > /dev/null 2>&1', inline: true)

          say_error 'Proton CLI (pass-cli) is not installed or not found in PATH. Please install it to fetch secrets from Proton Vault.'
          raise Thor::Error, 'Proton CLI (pass-cli) is required but not found in PATH.'
        end

        def vault_share_id
          vault_credentials.vault_share_id
        end

        def vault_source_items
          @vault_sources ||= {
            shared:
              VaultSourceItem
                .new(
                  share_id: vault_credentials.shared_env_vars_item_id,
                  name: 'Environment variables (shared)'
                ),
            production:
              VaultSourceItem
                .new(
                  share_id: vault_credentials.production_env_vars_item_id,
                  name: 'Environment variables (production)'
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
