# frozen_string_literal: true

require_relative 'utils/class_helpers'
require_relative 'runnable'

module LarCity
  module CLI
    module GitOpsHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        require_thor_options_support!(base)

        base.include OutputHelpers
        base.include Runnable
        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        def require_gh_cli!
          return if run('which gh > /dev/null 2>&1', mock_return: true, eval: false, inline: true)

          say_warning <<~MSG.squish
            The 'gh' CLI tool is not installed or not found in the system PATH.
            Please install the GitHub CLI to use this command. You can install it via
            Brew by running 'brew install gh' or by following the instructions at
            https://cli.github.com/manual/installation.
          MSG
          raise Thor::Error, 'GitHub CLI (gh) is required but not found in PATH.'
        end

        def current_branch
          @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
        end

        def branches
          @branches ||= `git branch --list`.split("\n").map.with_index do |b, i|
            branch_opts = {}
            # The current branch will have the "*" prefix
            branch_opts[:current] = true if b.start_with?('*')
            # A branch with a worktree will have a "+" prefix
            branch_opts[:worktree] = true if b.start_with?('+')
            [i, b.gsub(/^[*+]\s+/, '').strip, branch_opts]
          end
        end
      end
    end
  end
end
