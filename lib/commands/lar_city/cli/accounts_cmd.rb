# frozen_string_literal: true

require 'terminal-table'
require_relative 'base_cmd'

module LarCity
  module CLI
    class AccountsCmd < BaseCmd
      attr_reader :accounts, :current_account, :primary_account

      namespace 'accounts'

      option :id, type: :string, desc: 'The ID of the account to update'
      option :slug, type: :string, desc: 'The slug of the account to update'
      desc 'sync', 'Sync accounts with the CRM'
      def sync
        with_interruption_rescue do
          lookup_account
          Zoho::API::Account.upsert(current_account, pretend: dry_run?)
        end
      end

      option :query_string,
             desc: 'The query to search for',
             type: :string,
             aliases: %w[--qs -q]
      desc 'dedupe', 'Consolidate duplicate accounts'
      def dedupe
        with_interruption_rescue do
          prompt_for_query_string_search if qs.blank?
          filtered_params =
            ActionController::Parameters
              .new(options.merge(s: { updatedAt: 'desc' }))
              .permit(:q, f: {}, s: {})
          if verbose?
            input = { qs:, filtered_params: }
            ap input
          end
          @search_query = AccountSearchQuery.new(qs, params: filtered_params)
          if verbose?
            output = {
              predicates: @search_query.predicates,
              sorters: @search_query.sorters
            }
            ap output
          end
          @query = Account.ransack(@search_query.predicates)
          @query.sorts = @search_query.sorters if @search_query.sorters.any?
          @accounts = @query.result(distinct: true)
          puts
          if accounts.any?
            say "Found #{tally(accounts, 'account')} that might be duplicates", Colors::INFO
            puts

            if accounts.size > row_display_limit
              say "Displaying the first #{row_display_limit} of #{accounts.size} accounts", Colors::HIGHLIGHT
              puts
            end

            output_matched_accounts(limited: accounts.size > row_display_limit)
            until (@primary_account = prompt_for_primary_account_selection)
              output_matched_accounts(limited: accounts.size > row_display_limit)
            end
            raise StandardError, 'No primary account selected' if primary_account.blank?

            # TODO: Offer to merge accounts by setting the most recently updated
            #   (should be the first in the list) as the "parent" account of
            #   the duplicates
            duplicate_ids = accounts.pluck(:id).reject { |id| id == primary_account.id }
            duplicate_phrase = 'duplicate'.pluralize(duplicate_ids.length)
            Account.transaction do
              # Clear the primary_account_id of the primary account (if set)
              if primary_account.parent.present?
                cleanup_msg = "⏳ Ensuring account #{primary_account.slug} (primary) isn't marked as a duplicate account"
                say cleanup_msg, Colors::INFO
                primary_account.update!(parent_id: nil)
                puts
              end
              # Unassign any accounts with the duplicates set as their parent
              say '⏳ Un-assigning duplicate accounts as parents', Colors::INFO
              _unassign_dupes_as_parents_result = Account.where(parent_id: duplicate_ids).update_all(parent_id: nil)
              puts
              # Make the primary account the parent of the duplicates
              say "⏳ Assigning account #{primary_account.slug} as parent of #{duplicate_phrase}", Colors::INFO
              result =
                Account
                  .where(id: duplicate_ids)
                  .update_all(parent_id: primary_account.id)
              if result
                success_msg = "🎉 Successfully marked #{tally(duplicate_ids, 'account')} as #{duplicate_phrase}"
                say success_msg, Colors::SUCCESS
              end
              # Rollback changes if in "pretend" mode
              raise ActiveRecord::Rollback if dry_run?
            end
          end
        end
      end

      no_commands do
        def lookup_account
          @current_account = lookup_by_id || lookup_by_slug
          raise ArgumentError, 'No account found' if current_account.blank?

          current_account
        end

        def qs
          @qs ||= options[:query_string]
        end

        def row_display_limit
          ENV.fetch('PREVIEW_ROW_DISPLAY_LIMIT', 5).to_i
        end

        def prompt_for_primary_account_selection
          raise StandardError, 'No accounts found' if accounts.blank?

          prompt_msg = <<~PROMPT
            Select the account to mark as "primary" (\
            #{range(accounts.first(row_display_limit))}, \
            or press "Ctrl + C" to quit):
          PROMPT
          input = ask(prompt_msg, Colors::PROMPT).chomp
          available_row_numbers = accounts_as_rows.map(&:first).map(&:to_s)
          # Handle invalid input
          unless available_row_numbers.include?(input)
            say 'Invalid selection. Please try again.', :red
            puts
            return
          end

          record_index = input.to_i - 1
          accounts[record_index].presence
        end

        def prompt_for_query_string_search
          @qs = ask('Enter a query string to search for accounts: ', Colors::PROMPT).chomp
        end

        def output_matched_accounts(limited: false)
          rows = limited ? accounts_as_rows.first(row_display_limit) : accounts_as_rows
          # TODO: Inspect the rows to see if the table is being built correctly
          table = ::Terminal::Table.new(
            headings: ['#', 'Slug', 'Display Name', 'Email', 'Tax ID'],
            rows:
          )
          puts table
          ap(rows) if verbose?
          puts
        end

        def accounts_row_numbers
          accounts_as_rows.map(&:first).map(&:to_s)
        end

        def accounts_as_rows
          @accounts_as_rows ||=
            accounts
              .pluck(:slug, :display_name, :email, :tax_id)
              .map.with_index do |account, index|
                [index + 1, account].flatten
              end
        end
      end

      private

      def lookup_by_id
        return unless options[:id].present?

        Account.find_by(id: options[:id])
      end

      def lookup_by_slug
        return unless options[:slug].present?

        Account.find_by(slug: options[:slug])
      end
    end
  end
end
