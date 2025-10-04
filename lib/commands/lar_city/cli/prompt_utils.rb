# frozen_string_literal: true

require 'highline'
require 'commands/lar_city/cli/types'

module LarCity
  module CLI
    class PromptUtils
      class << self
        def enter_basic_auth_credentials(cli: HighLine.new, creating: false)
          username_prompt =
            if creating
              "#{I18n.t('globals.prompts.basic_auth.new_username')}:"
            else
              "#{I18n.t('globals.prompts.basic_auth.username')}:"
            end

          password_prompt =
            if creating
              "#{I18n.t('globals.prompts.basic_auth.new_password')}:"
            else
              "#{I18n.t('globals.prompts.basic_auth.password')}:"
            end

          confirm_password_prompt =
            "#{I18n.t('globals.prompts.basic_auth.confirm_password')}:"

          username = cli.ask(username_prompt) { |q| q.validate = /\A\w+\Z/ }
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

          { username:, password: }
        end
      end
    end
  end
end
