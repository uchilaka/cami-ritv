# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity::CLI
  class DevkitCmd < BaseCmd
    namespace 'devkit'

    option :interactive,
           type: :boolean,
           aliases: '-i',
           desc: 'Run in interactive mode',
           default: true
    option :branch_name,
           type: :string,
           aliases: %w[-b --branch],
           desc: 'The name of the branch to create'
    option :output,
           type: :string,
           aliases: '-o',
           enum: %w[inline web],
           default: 'web',
           required: true
    desc 'peek', 'Check for branches with PRs available for review'
    def peek
      if interactive?
        say "Enter 'Ctrl + C' to quit at any time.", :cyan
        puts
        until (pr_number = check_or_prompt_for_branch_to_review)
          @selected_branch = prompt_for_branch_selection('Check another branch?')
        end
      else
        pr_number = check_or_prompt_for_branch_to_review
      end
      say "PR number: #{pr_number}", :green

      case options[:output]
      when 'web'
        run "gh pr view #{pr_number} --web", inline: true
      else
        run "gh pr view #{pr_number}", inline: true
      end
    rescue SystemExit, Interrupt => e
      say "\nTask interrupted.", :red
      exit(1) unless verbose?
      raise e
    rescue StandardError => e
      say "An error occurred: #{e.message}", :red
      exit(1) unless verbose?
      raise e
    end

    desc 'swaggerize', 'Generate Swagger JSON file(s)'
    def swaggerize
      cmd = 'bundle exec rails rswag'
      if verbose?
        puts <<~CMD
          Executing#{dry_run? ? ' (dry-run)' : ''}: #{cmd}
        CMD
      end

      return if dry_run?

      ClimateControl.modify RAILS_ENV: 'test' do
        system(cmd)
      end
    end

    desc 'logs', 'Show the logs for the project'
    def logs
      raise Errors::UnsupportedOSError, 'Unsupported OS' unless mac?

      cmd = "open --url #{log_stream_url}"
      if verbose?
        puts <<~CMD
          Executing#{dry_run? ? ' (dry-run)' : ''}: #{cmd}
        CMD
      end
      system(cmd) unless dry_run?
    end

    no_commands do
      def check_or_prompt_for_branch_to_review
        say "Checking branch status for #{selected_branch}...", :yellow
        check_pr_cmd = "gh pr list --head #{selected_branch} --json number -q '.[].number'"
        if dry_run?
          get_pr_number_cmd = <<~CMD
            Executing#{dry_run? ? ' (dry-run)' : ''}: #{check_pr_cmd}
          CMD
          say(get_pr_number_cmd, :magenta)
          return
        end
        output = `#{check_pr_cmd}`.strip
        # TODO: Support "q" to quit (also show "Ctrl + C" to quit message)
        pr_number = output.to_i

        if pr_number.zero?
          say "🙅🏾‍♂️ No PR found for branch #{selected_branch}.", :red
          puts
          prompt_to_delete_branch(selected_branch) if interactive?
          return
        end

        pr_number
      end

      def prompt_to_delete_branch(branch)
        input = ask("⚠️ Delete the #{branch} branch (ONLY CONTINUE IF YOU'RE SURE)? (y/n)").chomp

        if input.casecmp('n').zero?
          puts
          return
        end

        if %w[master main].include?(branch)
          say "Branch #{branch} wasn't deleted (should be protected).", :red
          puts
          return
        end

        if run("git branch --delete #{selected_branch}", inline: true)
          say "Branch #{branch} deleted.", :green
          @selected_branch = nil
          @branches = nil
        else
          say "Branch #{branch} could not be deleted.", :red
        end

        puts
      end

      def prompt_for_branch_selection(context_msg = nil)
        if @branches.nil?
          say output_available_branches(context_msg)
        else
          say context_msg || 'Select a branch:'
        end
        puts
        input = ask('👉🏾 Enter the number of the branch to review:').chomp
        return current_branch_tuple.last if input.blank?

        available_branch_numbers = branches.map(&:first).map { |i| (i + 1).to_s }
        raise ArgumentError, 'Invalid branch number' unless available_branch_numbers.include?(input)

        # The user input is 1-based, but the array is 0-based
        branches[input.to_i - 1].last
      end

      def output_available_branches(branch_list_hr)
        branch_list_hr ||= "Available #{'branch'.pluralize(branches.size)}:"
        <<~PROMPT_MSG
          #{branch_list_hr}
          #{'=' * branch_list_hr.size}
          #{branches.map { |i, b| "#{i + 1}. #{is_current_branch_phrase(b)}#{b}" }.join("\n")}
        PROMPT_MSG
      end

      def branches
        @branches ||=
          if @branches.blank?
            `git branch --list`.split("\n").map.with_index do |b, i|
              [i, b.gsub('*', '').strip]
            end
          end
      end

      def is_current_branch_phrase(branch)
        if branch == current_branch
          '* '
        else
          ''
        end
      end
    end

    no_commands do
      def check_or_prompt_for_branch_to_review
        say "Checking branch status for #{selected_branch}...", :yellow
        check_pr_cmd = "gh pr list --head #{selected_branch} --json number -q '.[].number'"
        if dry_run?
          get_pr_number_cmd = <<~CMD
            Executing#{dry_run? ? ' (dry-run)' : ''}: #{check_pr_cmd}
          CMD
          say(get_pr_number_cmd, :magenta)
          return
        end
        output = `#{check_pr_cmd}`.strip
        # TODO: Support "q" to quit (also show "Ctrl + C" to quit message)
        pr_number = output.to_i

        if pr_number.zero?
          say "🙅🏾‍♂️ No PR found for branch #{selected_branch}.", :red
          puts
          prompt_to_delete_branch(selected_branch) if interactive?
          return
        end

        pr_number
      end

      def prompt_to_delete_branch(branch)
        input = ask("⚠️ Delete the #{branch} branch (ONLY CONTINUE IF YOU'RE SURE)? (y/n)").chomp

        if input.casecmp('n').zero?
          puts
          return
        end

        if %w[master main].include?(branch)
          say "Branch #{branch} wasn't deleted (should be protected).", :red
          puts
          return
        end

        if run("git branch --delete #{selected_branch}", inline: true)
          say "Branch #{branch} deleted.", :green
          @selected_branch = nil
          @branches = nil
        else
          say "Branch #{branch} could not be deleted.", :red
        end

        puts
      end

      def prompt_for_branch_selection(context_msg = nil)
        if @branches.nil?
          say output_available_branches(context_msg)
        else
          say context_msg || 'Select a branch:'
        end
        puts
        input = ask('👉🏾 Enter the number of the branch to review:').chomp
        return current_branch_tuple.last if input.blank?

        branch_number = branches.map(&:first).map { |i| (i + 1).to_s }
        raise ArgumentError, 'Invalid branch number' unless branch_number.include?(input)

        # The user input is 1-based, but the array is 0-based
        branches[input.to_i - 1].last
      end

      def output_available_branches(branch_list_hr)
        branch_list_hr ||= "Available #{'branch'.pluralize(branches.size)}:"
        <<~PROMPT_MSG
          #{branch_list_hr}
          #{'=' * branch_list_hr.size}
          #{branches.map { |i, b| "#{i + 1}. #{is_current_branch_phrase(b)}#{b}" }.join("\n")}
        PROMPT_MSG
      end

      def branches
        @branches ||=
          if @branches.blank?
            `git branch --list`.split("\n").map.with_index do |b, i|
              [i, b.gsub('*', '').strip]
            end
          end
      end

      def is_current_branch_phrase(branch)
        if branch == current_branch
          '* '
        else
          ''
        end
      end
    end

    private

    def interactive?
      options[:interactive]
    end

    def selected_branch
      @selected_branch ||=
        if @selected_branch.blank?
          branch_name = options[:branch_name]
          branch_name ||= prompt_for_branch_selection
          branch_name
        end
    end

    def current_branch_tuple
      @current_branch_tuple ||= branches.find { |_, b| b == current_branch }
    end

    def current_branch
      @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
    end

    def log_stream_url
      team_id, source_id = Rails.application.credentials.betterstack.values_at :team_id, :source_id
      "https://logs.betterstack.com/team/#{team_id}/tail?s=#{source_id}"
    end
  end
end
