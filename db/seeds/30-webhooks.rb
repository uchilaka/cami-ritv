# frozen_string_literal: true

require 'lib/commands/lar_city/cli/devkit_cmd'

LarCity::CLI::DevkitCmd.new.invoke(:setup_webhooks, [], verbose: Rails.env.development?)
