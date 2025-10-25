# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class DevkitCmd < BaseCmd
      namespace 'devkit'

      option :force,
             desc: 'Force an upsert operation on any matching webhook (by vendor)',
             type: :boolean,
             default: false
      option :vendor,
             desc: 'The vendor to use for the devkit',
             type: :string,
             aliases: '-s',
             enum: %w[zoho notion],
             required: true
      desc 'setup_webhooks', 'Setup webhooks for the project'
      def setup_webhooks
        if Rails.env.test?
          say_highlight('🚫 Skipping webhook setup in test environment')
          return
        end

        with_interruption_rescue do
          case options[:vendor]
          when 'notion'
            integration_id, verification_token, deal_database_id =
              Rails.application.credentials.notion&.values_at :integration_id, :verification_token, :deal_database_id
            dashboard_url = "https://www.notion.so/profile/integrations/internal/#{integration_id}"
            records_index_workflow_name = 'Notion::DownloadLatestDealsWorkflow'
            record_download_workflow_name = 'Notion::DownloadDealWorkflow'
            ::Webhook.transaction do
              webhook =
                ::Webhook
                  .find_or_initialize_by(
                    slug: options[:vendor],
                    verification_token:
                  )
              updates = {
                integration_id:,
                deal_database_id:,
                dashboard_url:,
                records_index_workflow_name:,
                record_download_workflow_name:,
              }.compact

              if verbose?
                if webhook.persisted?
                  ap webhook, options: { indent: 2 }
                  say "⏳️ Updating webhook '#{webhook.slug}'", :magenta
                else
                  say "⏳️ Setting up webhook '#{options[:vendor]}'", :yellow
                end
                ap updates, options: { indent: 2 }
              end

              if webhook.new_record? || options[:force]
                webhook.data = { integration_id:, deal_database_id:, dashboard_url: }.compact
                if webhook.changed?
                  webhook.save!
                  say "⚡ Webhook for #{options[:vendor]} has been set up successfully.", :green
                else
                  say "💅🏾 Webhook for #{options[:vendor]} is already set up and no changes were made.", :cyan
                end
              else
                updates.each { |k, v| webhook.send(:"#{k}=", v) if webhook.respond_to?("#{k}=") }
                if webhook.changed?
                  webhook.save!
                  say "⚡ Webhook for #{options[:vendor]} has been updated successfully.", :green
                else
                  say "💅🏾 Webhook for #{options[:vendor]} is already up to date.", :cyan
                end
              end
              raise ActiveRecord::Rollback if dry_run?
            end
          when 'zoho'
            raise NotImplementedError
          else
            raise ArgumentError, "Unsupported vendor: #{options[:vendor]}"
          end
        end
      end

      desc 'yeet_deploy', 'Shove the current code to production'
      long_desc <<-LONGDESC
        🚨 WARNING: This command forcefully deploys the current code to production
        without any checks or confirmations.

        This deployment pipeline operates via the releases/production branch and a deploy
        hook configured in the repository settings on the hosting platform.

        This deployment method is highly discouraged for regular use and should only
        be used in emergency situations where immediate action is required to resolve
        critical issues.
      LONGDESC
      def yeet_deploy
        # Check to make sure current branch is clean (no dangling changes)
        with_interruption_rescue do
          status_output = `git status --porcelain`.strip
          unless status_output.blank?
            raise 'Current branch has uncommitted changes. Please commit or stash them before deploying.'
          end

          # run 'git fetch origin', inline: true
          run 'git pull --ff-only', inline: true
          # run 'git fetch origin releases/production', inline: true
          # run 'git pull origin releases/production', inline: true
          run 'git push', inline: true

          # Save current branch
          working_branch = `git rev-parse --abbrev-ref HEAD`.strip
          target_branch = 'releases/production'
          if working_branch == target_branch
            raise 'You are already on the releases/production branch. Please switch to another branch before deploying.'
          end

          # Merge the current branch into the target releases/* branch
          checkout_cmd = "git checkout #{target_branch}"
          run checkout_cmd, inline: true

          success = system(checkout_cmd)
          raise "Failed to checkout #{target_branch} branch." unless success

          commit_msg = <<~COMMIT_MSG
            Merging #{working_branch} into #{target_branch} for emergency deploy
          COMMIT_MSG
          merge_cmd = "git merge --no-ff #{working_branch} -m '#{commit_msg.strip}'"
          run merge_cmd, inline: true

          deploy_cmd = ['git push origin', "HEAD:#{target_branch}"]
          success = run(*deploy_cmd, inline: true)
          raise 'Deployment failed. Please check the output above for details.' unless success || pretend?

          say_success "🚀 Code has been forcefully deployed to #{target_branch}."
          system("git switch #{working_branch}")
        end
      end

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
end
