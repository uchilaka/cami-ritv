# frozen_string_literal: true

require 'highline'
require 'commands/lar_city/cli/types'

module LarCity
  module CLI
    class PromptUtils
      class << self
        def prompt_for_auth_credentials(cli: HighLine.new, creating: false)
          username =
            prompt_for_username(cli:, creating:)
          password =
            prompt_for_password(cli:, creating:)
          { username:, password: }
        end

        def prompt_for_username(cli: HighLine.new, creating: false)
          username_prompt =
            if creating
              "#{I18n.t('globals.prompts.auth.new_username')}:"
            else
              "#{I18n.t('globals.prompts.auth.username')}:"
            end
          cli.ask(username_prompt) { |q| q.validate = /\A\w+\Z/ }
        end

        def prompt_for_password(cli: HighLine.new, creating: false)
          password_prompt =
            if creating
              "#{I18n.t('globals.prompts.auth.new_password')}:"
            else
              "#{I18n.t('globals.prompts.auth.password')}:"
            end

          confirm_password_prompt =
            "#{I18n.t('globals.prompts.auth.confirm_password')}:"

          password = cli.ask(password_prompt) do |q|
            q.validate = Types::Coercible::String
            q.echo = '*'
          end
          confirm_password =
            if creating
              cli.ask(confirm_password_prompt) do |q|
                q.validate = Types::Coercible::String
                q.echo = '*'
              end
            end

          # If creating, ensure password and confirm_password match
          if creating && password != confirm_password
            raise Thor::Error, I18n.t('globals.validators.errors.password_mismatch')
          end

          password
        end
      end
    end
  end
end
