# frozen_string_literal: true

require 'rails_helper'
require 'open3'

# Contracts that keep a test run from inheriting a development-shaped environment.
#
# These guard three regressions that have each actually happened on this branch, and that
# ordinary unit tests cannot catch because they live in config files rather than code:
#
#   1. config/database.yml defaulting the TEST database to a development name
#   2. the RubyMine RSpec template losing RAILS_ENV=test, or pinning one worktree's name
#   3. .envrc validating RUBY_ENV only AFTER interpolating it into env file paths
RSpec.describe 'environment isolation' do
  describe 'config/database.yml' do
    # The `test:` defaults are the last line of defence. spec/rails_helper.rb aborts on a
    # non-"_test" database, but only because this default is test-shaped -- point it at
    # sails_development and a bare `RAILS_ENV=test` run resolves the development database,
    # which DatabaseCleaner then truncates.
    subject(:test_databases) do
      rendered = ERB.new(File.read(Rails.root.join('config/database.yml'))).result(binding)
      YAML.safe_load(rendered, aliases: true).fetch('test')
    end

    # Render with the variables UNSET, so the ERB falls through to its literal defaults.
    around do |example|
      keys = %w[APP_DATABASE_NAME_PRIMARY APP_DATABASE_NAME_CRM]
      saved = ENV.to_hash.slice(*keys)
      keys.each { |key| ENV.delete(key) }
      example.run
      saved.each { |key, value| ENV[key] = value }
    end

    it 'defaults the primary test database to a test-suffixed name' do
      expect(test_databases.dig('primary', 'database')).to end_with('_test')
    end

    it 'defaults the queue test database to a test-suffixed name' do
      expect(test_databases.dig('queue', 'database')).to end_with('_test')
    end

    it 'defaults the crm test database to a test-suffixed name' do
      expect(test_databases.dig('crm', 'database')).to end_with('_test')
    end
  end

  describe '.ide-configs/Template RSpec.run.xml' do
    subject(:template) do
      Nokogiri::XML(File.read(Rails.root.join('.ide-configs/Template RSpec.run.xml')))
    end

    # Without this, RubyMine's built-in run controls boot the app in development and the
    # suite either aborts on the database guard or dies decrypting credentials.
    it 'presets RAILS_ENV=test' do
      node = template.at_xpath('//envs/env[@name="RAILS_ENV"]')

      expect(node&.attr('value')).to eq('test')
    end

    # `<module name="pr-293"/>` pinned the directory name of whichever worktree generated
    # the file, so it resolved for exactly one checkout and silently failed elsewhere.
    it 'does not pin a checkout-specific module name' do
      expect(template.at_xpath('//module')).to be_nil
    end
  end

  describe '.envrc' do
    # Comments in .envrc quote these very tokens while explaining the two-phase load, so
    # compare CODE positions only -- otherwise the prose matches first and the assertion
    # reports the wrong ordering.
    let(:source) do
      File.read(Rails.root.join('.envrc'))
        .lines
        .reject { |line| line.strip.start_with?('#') }
        .join
    end

    # The structural half of the two-phase load: the paths that interpolate RUBY_ENV must
    # come AFTER the guard. Built up front, "${RUBY_ENV}" expands while still empty,
    # ".env.${RUBY_ENV}" silently becomes ".env.", and the environment-specific file is
    # skipped rather than reported as missing.
    it 'validates RUBY_ENV before interpolating it into env file paths' do
      guard = source.index('${RUBY_ENV:?')
      interpolation = source.index('.env.${RUBY_ENV}')

      expect(guard).to be_present
      expect(interpolation).to be_present
      expect(guard).to be < interpolation
    end

    # ...and the behavioural half. Skipped when a base dotenv file supplies RUBY_ENV,
    # since the guard then legitimately does not fire.
    let(:base_dotenv_defines_ruby_env) do
      %w[.env .env.local].any? do |file|
        path = Rails.root.join(file)
        path.exist? && path.read.match?(%r{^\s*(export\s+)?RUBY_ENV=})
      end
    end

    it 'refuses to load when RUBY_ENV is absent' do
      skip 'a base dotenv file defines RUBY_ENV, so the guard cannot fire' if base_dotenv_defines_ruby_env

      output, status = Open3.capture2e(
        { 'RUBY_ENV' => nil }, 'bash', '-c', 'source .envrc', chdir: Rails.root.to_s
      )

      aggregate_failures do
        expect(status).not_to be_success
        expect(output).to include('RUBY_ENV is not set')
      end
    end
  end
end
