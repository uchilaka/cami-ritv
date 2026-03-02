# frozen_string_literal: true

require 'lar_city/cli/utils'

module LarCity
  module CLI
    class EnvCmd < BaseCmd
      namespace :env

      no_commands do
        include VaultHelpers
        include Runnable
      end

      option :format,
             type: :string,
             desc: 'Output format (json or yaml)',
             enum: %w[json yaml],
             default: 'yaml'
      desc 'list-items', 'List environment variable items from Vault'
      def list_items
        result =
          run(
            'pass-cli item list',
            "--share-id #{vault_share_id}",
            "--output #{options[:format]}", inline: true, eval: true
          )
        items = JSON.parse(result)
        say_info items.to_yaml
      end
    end
  end
end
