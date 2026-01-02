# frozen_string_literal: true

# See https://stackoverflow.com/a/837593/3726759
app_path = File.join(Dir.pwd, 'app')
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'thor/group'
require 'awesome_print'
require 'concerns/operating_system_detectable'
require 'lar_city/cli/utils'
require 'lar_city/cli/interruptible'
require 'lar_city/cli/reversible'
require 'lar_city/cli/runnable'

module LarCity
  module BaseCmdStack
    def self.included(base)
      # TODO: Is this "no_commands" block wrapper necessary?
      base.no_commands do
        base.include OperatingSystemDetectable
        base.include LarCity::CLI::EnvHelpers
        base.include LarCity::CLI::OutputHelpers
      end

      LarCity::CLI::EnvHelpers.define_class_options(base)
      LarCity::CLI::OutputHelpers.define_class_options(base)

      # TODO: Is this "no_commands" block wrapper necessary?
      base.no_commands do
        base.include LarCity::CLI::Interruptible
        base.include LarCity::CLI::Reversible
        base.include LarCity::CLI::Runnable
      end
    end
  end
end
