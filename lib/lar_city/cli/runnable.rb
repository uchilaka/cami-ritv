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

        # Runs a system command with support for dry-run mode, verbose output, and
        # optional inline output processing when a block is given.
        def run(*args, inline: false, mock_return: nil, eval: false, &block)
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
            return mock_return if dry_run?

            result =
              if block_given?
                output_buffer = []
                status =
                  Open3.popen2e(cmd) do |_stdin, stdout_stderr, wait_thread|
                    reader_thread =
                      Thread.new do
                        stdout_stderr.each do |line|
                          output_buffer << line if eval
                          block.call(line)
                        end
                      end

                    process_status = wait_thread.value
                    reader_thread.join # Wait for the reader thread to finish before the stream is closed
                    process_status.success?
                  end
                eval ? output_buffer.join : status
              elsif eval
                `#{cmd}`
              else
                system(cmd, out: $stdout, err: :out)
              end
            # Return the result if inline, otherwise return nil. This avoids
            # unintended consequences of returning command output in non-inline contexts
            result if eval || inline
          end
        end
      end
    end
  end
end
