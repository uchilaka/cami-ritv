# frozen_string_literal: true

require 'open3'

module LarCity
  module CLI
    module Runnable
      extend Utils::ClassHelpers

      def self.included(base)
        # Throw an error unless included in a Thor class
        raise "#{name} can only be included in Thor or Thor::Group descendants" unless has_thor_ancestor?(base)

        base.include OutputHelpers
        base.include Interruptible

        # Make InstanceMethods available to the base context
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        def run(*args, inline: false, eval: false, &block)
          with_interruption_rescue do
            cmd = args.compact.join(' ')
            if verbose? || dry_run?
              msg = <<~CMD
                Executing#{dry_run? ? ' (dry-run)' : ''}: #{cmd}
              CMD
              if dry_run?
                say_highlight msg
              else
                say_info msg
              end
            end
            return if dry_run?

            if eval
              if block_given?
                # Example: doing this with Open3
                Open3.popen2e(cmd) do |_stdin, stdout_stderr, wait_thread|
                  Thread.new do
                    stdout_stderr.each(&block)
                  end
                  wait_thread.value
                end
              else
                result = `#{cmd}`
                return result
              end
            else
              result = system(cmd, out: $stdout, err: :out)
              return result if inline

              # exit 0 if result
            end
          end
        end
      end
    end
  end
end
