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
        attr_reader :runnable_mode, :runnable_io_mode, :runnable_result

        protected

        # Runs a system command with support for dry-run mode, verbose output, and
        # optional inline output processing when a block is given.
        def run(
          *args,
          # @deprecated use io_mode instead
          inline: nil,
          # @deprecated use io_mode instead
          eval: nil,
          io_mode: nil, # inline | eval | inline_with_result | eval_with_result
          mode: nil, # always_run | always_mock
          mock_return: nil,
          &block
        )
          @runnable_io_mode =
            if eval == true && inline == true
              'eval_with_result'
            elsif eval == true
              'eval_with_result'
            elsif inline == true
              'inline_with_result'
            else
              'inline'
            end
          validate_runnable_mode!(mode) if mode.present?
          validate_runnable_io_mode!(io_mode) if io_mode.present?
          with_interruption_rescue do
            cmd = args.compact.join(' ')
            if verbose? || mock_runnable_run?
              msg = <<~CMD
                Executing#{dry_run? ? ' (dry-run)' : ''}: #{cmd}
              CMD
              if dry_run?
                say_highlight msg
              else
                say_info msg
              end
            end
            return mock_return if mock_runnable_run?

            @runnable_result =
              if block_given?
                output_buffer = []
                status =
                  Open3.popen2e(cmd) do |_stdin, stdout_stderr, wait_thread|
                    reader_thread =
                      Thread.new do
                        stdout_stderr.each do |line|
                          # TODO: There was a condition on eval for this line - review later.
                          output_buffer << line
                          block.call(line)
                        end
                      end

                    process_status = wait_thread.value
                    reader_thread.join # Wait for the reader thread to finish before the stream is closed
                    process_status
                  end
                runnable_eval? ? output_buffer.join : status
              elsif runnable_eval?
                `#{cmd}`
              else
                # Default: runnable_io_mode == 'inline' behavior
                system(cmd, out: $stdout, err: :out)
              end
          end
        ensure
          runnable_reset!
          # Return the result if inline, otherwise return nil. This avoids
          # unintended consequences of returning command output in non-inline contexts
          runnable_result if runnable_io_with_result?
        end

        def always_run?
          runnable_mode == 'always_run'
        end

        def mock_runnable_run?
          pretend? || runnable_mode == 'always_mock'
        end

        def runnable_eval?
          runnable_io_mode == 'eval'
        end

        def runnable_io_with_result?
          runnable_io_mode.to_s.ends_with?('_with_result')
        end

        def runnable_reset!
          @runnable_mode = nil
          @runnable_io_mode = nil
        end

        private

        def validate_runnable_mode!(value = nil)
          @runnable_mode = value.to_s if value.present?
          unless runnable_mode.blank? || %w[always_run always_mock].include?(runnable_mode)
            raise ArgumentError, "Unsupported mode: '#{runnable_mode}'"
          end
        end

        def validate_runnable_io_mode!(value = nil)
          @runnable_io_mode = value.to_s if value.present?
          valid_values = %w[inline eval inline_with_result eval_with_result]
          unless runnable_io_mode.blank? || valid_values.include?(runnable_io_mode)
            raise ArgumentError, "Unsupported IO mode: '#{runnable_io_mode}'"
          end
        end
      end
    end
  end
end
