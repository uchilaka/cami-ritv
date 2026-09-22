# frozen_string_literal: true

require 'rails_helper'
require 'open3'

# Contracts that keep a test run from inheriting a development-shaped environment.
#
# These guard three regressions that have each actually happened on this branch, and that
# ordinary unit tests cannot catch because they live in config files rather than code:
#
#   1. config/database.yml defaulting the TEST database to a development name
#   2. .envrc validating RUBY_ENV only AFTER interpolating it into env file paths
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

  # R1 the selector (RUBY_ENV) is set by the shell, never by a file it selects.
  # R2 .env / .env.local hold nothing environment-shaped -- a default there is exactly how
  #    the wrong environment comes to look right.
  # R3 each .env.<env> declares RAILS_ENV, and it agrees with the filename.
  describe 'dotenv file conventions' do
    # git-crypt leaves locked files starting with "\0GITCRYPT". CI never unlocks, so skip
    # rather than assert against ciphertext. .env.test is deliberately exempt from
    # encryption so at least one environment stays legible everywhere.
    def locked?(path)
      path.binread(9) == "\x00GITCRYPT".b
    end

    def declared_variables(path)
      path.read.scan(%r{^[ \t]*(?:export[ \t]+)?([A-Z_][A-Z0-9_]*)=}).flatten
    end

    # `.example` templates are documentation, not environments -- they hold placeholder
    # values and must not be held to R3.
    env_specific_files =
      Dir.glob(Rails.root.join('.env.*')).reject { |f| f.end_with?('.local', '.example') }.sort

    env_specific_files.each do |file|
      environment = File.basename(file).delete_prefix('.env.')

      context File.basename(file) do
        let(:path) { Pathname.new(file) }

        before { skip "#{File.basename(file)} is git-crypt locked" if locked?(path) }

        it "declares RAILS_ENV=#{environment}" do
          expect(path.read)
            .to match(%r{^[ \t]*(?:export[ \t]+)?RAILS_ENV=["']?#{Regexp.escape(environment)}["']?[ \t]*$})
        end

        it 'leaves RUBY_ENV to the shell' do
          expect(declared_variables(path)).not_to include('RUBY_ENV')
        end
      end
    end

    # `.env` is committed and shared, so a selector there is a cross-environment default --
    # every machine would claim the same environment. `.env.local` is untracked and loads
    # in phase 1, BEFORE the selector is used, so it is the one legitimate place for a
    # machine to declare which environment it is. RAILS_ENV/NODE_ENV stay out of both:
    # they are declared by .env.<env>, per R3.
    {
      '.env' => %w[RAILS_ENV RUBY_ENV NODE_ENV],
      '.env.local' => %w[RAILS_ENV NODE_ENV],
    }.each do |file, forbidden|
      context file do
        let(:path) { Rails.root.join(file) }

        before do
          skip "#{file} is not present" unless path.exist?
          skip "#{file} is git-crypt locked" if locked?(path)
        end

        # Intersection, not `not_to include(a, b, c)` -- that form only fails when ALL
        # of them are present, so it would pass with two of the three sitting there.
        it "declares none of #{forbidden.join(', ')}" do
          expect(declared_variables(path) & forbidden).to be_empty
        end
      end
    end

    # R2, payload half. The database ROLE differs per environment here, which makes the
    # whole connection environment-shaped -- it belongs in .env.<env>.local. It sat in
    # .env.local declaring port 5432, which is postgres.development.larcity: a different
    # project's server that rejects this project's user.
    context '.env.local (database connection)' do
      let(:path) { Rails.root.join('.env.local') }

      before do
        skip '.env.local is not present' unless path.exist?
        skip '.env.local is git-crypt locked' if locked?(path)
      end

      it 'does not declare a database connection' do
        expect(declared_variables(path).grep(%r{\AAPP_DATABASE_})).to be_empty
      end
    end
  end
end
