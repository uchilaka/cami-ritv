# frozen_string_literal: true

require_relative '../../commands/lar_city/cli/base_cmd'

module Fixtures
  class Users < LarCity::CLI::BaseCmd
    desc 'load', 'Load application users'
    def load
      say 'Loading users...', Color::YELLOW
      fixtures_to_load =
        if User.none?
          tally = fixtures.count
          say "Found #{tally} #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures
        else
          fixtures_to_load = fixtures.reject { |b| record_exists?(b) }
          tally = fixtures_to_load.count
          say "Found #{tally} new #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures_to_load
        end

      return if fixtures_to_load.empty?

      ap fixtures_to_load if verbose?
      return if dry_run?

      if fixtures_to_load.none?
        say 'No new users to load', Color::GREEN
        return
      end

      roles_to_set = {}

      # # Set passwords
      # fixtures_to_load = fixtures_to_load.map do |account|
      #   account[:password] = SecureRandom.alphanumeric(16)
      #   roles_to_set[account[:email]] = account.delete(:roles)
      #   account
      # end

      fixtures_to_load = fixtures_to_load.each_with_object([]) do |record, hash|
        record.symbolize_keys!
        # Set password
        record[:password] = SecureRandom.alphanumeric(16)
        # Capture roles (will process in a following block)
        roles_to_set[record[:email]] = record.delete(:roles)
        # Set prepared record
        hash << record
      end

      # Clean out any nil values
      roles_to_set.compact!

      User.transaction do
        # Process user records
        results = User.create!(fixtures_to_load)

        # Assign roles
        results.each do |user|
          roles_to_add = roles_to_set[user.email]
          next if user.invalid? || roles_to_add.blank?

          roles_to_add.each { |role| user.add_role(role.to_sym) }
        end

        # Report status in console
        if results.all?(&:valid?)
          Rails.logger.info "Saved #{results.count} records"
        else
          saved_records = results.reject { |record| record.errors.any? }
          Rails.logger.warn "Saved #{saved_records.count} of #{fixtures_to_load.count} records"
        end
      end
    end

    protected

    def things(count)
      'user'.pluralize(count)
    end

    private

    def record_exists?(record)
      User.exists?(email: record['email'])
    end

    def fixtures
      @fixtures ||= YAML.load(
        ERB.new(
          File.read(Rails.root.join('spec/fixtures/users.yml'))
        ).result
      )
    end
  end
end
