# frozen_string_literal: true

require 'commands/lar_city/cli/base_cmd'

module Fixtures
  class Accounts < LarCity::CLI::BaseCmd
    desc 'load', 'Load account fixtures'
    def load
      say 'Loading account fixtures...', Color::YELLOW
      fixtures_to_load =
        if Account.none?
          tally = fixtures.count
          say "Found #{tally} #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures
        else
          fixtures_to_load = fixtures.reject { |b| Account.exists?(slug: b['slug']) }
          tally = fixtures_to_load.count
          say "Found #{tally} new #{things(tally)} in the fixtures file.",
              Color::CYAN
          fixtures_to_load
        end

      return if fixtures_to_load.empty?

      ap fixtures_to_load if verbose?

      return if dry_run?

      # Create the new records
      result = Account.create(fixtures_to_load)
      if result.all?(&:valid?)
        say 'All records were created successfully.', Color::GREEN
      else
        say 'Some records could not be created.', Color::RED
        ap result.reject(&:valid?) if verbose?
      end

      return unless verbose?

      tally = Account.count
      say "There are now #{tally} #{things(tally)} in the database.", Color::MAGENTA
    end

    private

    def things(count)
      'business'.pluralize(count)
    end

    def fixtures
      @fixtures ||= YAML.load(
        ERB.new(
          File.read(Rails.root.join('spec/fixtures/accounts.yml').to_s)
        ).result
      ).map do |b|
        b.symbolize_keys!
        b[:slug] ||= b[:name].parameterize
        b
      end
    end
  end
end
