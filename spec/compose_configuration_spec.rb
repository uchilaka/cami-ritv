# frozen_string_literal: true

# Deliberately NOT rails_helper: every contract here reads files, so booting Rails would
# make a compose regression invisible whenever the test database is unreachable -- and CI
# should be able to enforce a fresh-clone contract without first provisioning a database.
# spec_helper is loaded for us by .rspec.
require 'open3'
require 'pathname'
require 'yaml'

# Contracts that keep `docker compose` working on a machine that is not the author's.
#
# These guard regressions that live in compose files and dotenv templates rather than in
# code, so no unit test reaches them:
#
#   1. a `${VAR:?}` guard added to compose.yml but documented in no tracked template --
#      which is how PLATFORM_SUBDOMAIN came to abort every compose command on every clone
#      except the one machine whose untracked .env.development.local happened to define it
#   2. an override that names a service or network the base file does not declare, which
#      Compose does not reject -- it invents the service, and you get a phantom with no
#      image instead of an error naming the typo
#
# compose.override.yml is gitignored, so the committed compose.override.yml.example is the
# artifact CI can actually hold to a standard. The same structural checks run against a
# real override when one is present, and skip when it is not.
RSpec.describe 'compose configuration' do
  # YAML comments are prose and must not be scanned for variable references. The
  # example file's own header explains the `${VAR:?...}` form, and scanning raw text
  # picks "VAR" up as a required variable that nothing could ever declare.
  def code_of(path)
    path.read.lines.reject { |line| line.strip.start_with?('#') }.join
  end

  def required_variables(path)
    code_of(path).scan(%r{\$\{([A-Z_][A-Z0-9_]*):\?}).flatten.uniq
  end

  def declared_variables(path)
    path.read.scan(%r{^[ \t]*(?:export[ \t]+)?([A-Z_][A-Z0-9_]*)=}).flatten
  end

  # git-crypt leaves locked files starting with "\0GITCRYPT".
  def locked?(path)
    path.exist? && path.binread(9) == "\x00GITCRYPT".b
  end

  # spec/ -> repository root. Mirrors what Rails.root would give, without booting Rails.
  let(:repo_root) { Pathname.new(__dir__).parent }

  let(:base_file) { repo_root.join('compose.yml') }
  let(:example_override) { repo_root.join('compose.override.yml.example') }
  let(:real_override) { repo_root.join('compose.override.yml') }

  # Only sources that are unencrypted in EVERY checkout. .env.development and friends are
  # git-crypt'd, so reading them would make this suite pass locally and fail in CI -- the
  # exact asymmetry these contracts exist to catch.
  let(:tracked_templates) do
    Dir.glob(repo_root.join('.env*'))
      .map { |f| Pathname.new(f) }
      .select { |p| p.file? && (p.to_s.end_with?('.example') || %w[.env .env.test].include?(p.basename.to_s)) }
      .reject { |p| locked?(p) }
      .sort
  end

  # Variables that are legitimately absent from every template, each for a stated reason.
  # Adding to this list is a deliberate act: a new `${VAR:?}` guard fails the suite until
  # it is either documented in a template or justified here.
  let(:exempt_from_templates) do
    {
      'APP_SECRET' => 'lives in the git-crypt encrypted .env.<env>, unreadable in CI',
      'GITCRYPT_KEY_BASE64' => 'derived by .envrc from $GITCRYPT_KEY_FILE; never hand-set',
    }.freeze
  end

  describe 'required variables are documented' do
    # The PLATFORM_SUBDOMAIN regression, made permanent. `:?` rejects an EMPTY value as
    # well as an unset one, so a declaration with a blank value still counts as documented
    # here -- the template's job is to name the variable, not to supply a secret.
    [%w[compose.yml], %w[compose.override.yml.example]].each do |(basename)|
      context basename do
        let(:path) { repo_root.join(basename) }

        it 'declares every `${VAR:?}` variable in a tracked, unencrypted template' do
          documented = tracked_templates.flat_map { |t| declared_variables(t) }.uniq
          undocumented = required_variables(path) - documented - exempt_from_templates.keys

          expect(undocumented).to be_empty,
                                  "#{basename} hard-requires #{undocumented.join(', ')}, which no tracked " \
                                  'template declares. Add it to the matching .env.*.example (see ' \
                                  'docs/DOCKER_COMPOSE.md) or, if it cannot be templated, to ' \
                                  'the exempt_from_templates list in this spec, with a reason.'
        end
      end
    end

    # Guards the exemption list itself. An entry that stops being needed should be removed,
    # otherwise the list slowly becomes a place to hide new undocumented variables.
    it 'carries no stale exemptions' do
      required = [base_file, example_override].flat_map { |p| required_variables(p) }.uniq
      documented = tracked_templates.flat_map { |t| declared_variables(t) }.uniq
      stale = exempt_from_templates.keys.select { |v| !required.include?(v) || documented.include?(v) }

      expect(stale).to be_empty
    end
  end

  # Compose does not error on an override for an unknown service -- it creates one. A
  # service renamed in compose.yml therefore leaves the override quietly defining a
  # container with no image, which surfaces much later and much less clearly.
  shared_examples 'a structurally valid override' do
    let(:base) { YAML.safe_load(code_of(base_file), aliases: true) }

    # Psych renders compose's `!reset` as nil and ignores `!override`, which is enough to
    # read the shape of the file. It is NOT equivalent to compose's merge semantics, so
    # nothing here should assert on merged VALUES -- only on which keys exist.
    let(:override) { YAML.safe_load(code_of(override_path), aliases: true) }

    it 'parses as YAML' do
      expect(override).to be_a(Hash)
    end

    it 'overrides only services that compose.yml declares' do
      unknown = (override['services'] || {}).keys - (base['services'] || {}).keys

      expect(unknown).to be_empty,
                         "#{override_path.basename} overrides #{unknown.join(', ')}, which compose.yml does " \
                         'not declare. Compose will invent these as new services rather than reject them.'
    end

    it 'references only networks that compose.yml declares' do
      declared = (base['networks'] || {}).keys
      unknown = (override['networks'] || {}).keys - declared

      expect(unknown).to be_empty
    end
  end

  describe 'compose.override.yml.example' do
    let(:override_path) { example_override }

    it 'is tracked, so a clone can copy it' do
      tracked = `git ls-files --error-unmatch #{override_path.basename} 2>/dev/null`

      expect(tracked.strip).to eq(override_path.basename.to_s)
    end

    it_behaves_like 'a structurally valid override'
  end

  # The user-facing half of the ask: when a real override is present, hold it to the same
  # structural contract. Absent (CI, a fresh clone), there is nothing to check.
  describe 'compose.override.yml' do
    let(:override_path) { real_override }

    before { skip 'no compose.override.yml present (it is gitignored)' unless real_override.exist? }

    it_behaves_like 'a structurally valid override'
  end

  # The end-to-end claim docs/DOCKER_COMPOSE.md makes: a clone holding only the tracked
  # templates, with the documented blanks filled, resolves a full compose configuration.
  # This is the check that would have caught PLATFORM_SUBDOMAIN even if someone had added
  # it to a template under a typo'd name.
  describe 'a fresh clone resolves' do
    # `!reset` and `!override` in the override file need Compose v2.24+. On an older CLI
    # they parse as unknown YAML tags and the file fails to load -- a failure that says
    # nothing about the contract under test, so name the cause and skip instead.
    let(:minimum_compose_version) { Gem::Version.new('2.24') }

    let(:compose_version) do
      out, status = Open3.capture2e('docker', 'compose', 'version', '--short')
      return nil unless status.success?

      Gem::Version.new(out.strip[%r{\A\d+(\.\d+)*}].to_s)
    rescue Errno::ENOENT, ArgumentError
      nil
    end

    # Build the environment a fresh clone would have: every value the tracked templates
    # supply, with a placeholder wherever the template deliberately leaves a blank.
    # unsetenv_others keeps the developer's own shell from masking a missing declaration --
    # the failure mode this whole file exists to prevent.
    let(:fresh_clone_env) do
      env = { 'PATH' => ENV.fetch('PATH', ''), 'HOME' => ENV.fetch('HOME', '') }
      tracked_templates.each do |template|
        template.read.scan(%r{^[ \t]*(?:export[ \t]+)?([A-Z_][A-Z0-9_]*)=(.*)$}).each do |name, raw|
          value = raw.strip.gsub(%r{\A["']|["']\z}, '')
          env[name] = value.empty? ? 'placeholder' : value
        end
      end
      exempt_from_templates.each_key { |name| env[name] = 'placeholder' }
      env
    end

    before do
      skip 'docker compose is unavailable, so the resolved configuration cannot be checked' if compose_version.nil?

      if compose_version < minimum_compose_version
        skip "docker compose #{compose_version} predates the !reset/!override merge tags " \
             "(needs #{minimum_compose_version}+)"
      end
    end

    it 'validates with the example override applied' do
      compose_file = [base_file, example_override].join(':')

      output, status = Open3.capture2e(
        fresh_clone_env.merge('COMPOSE_FILE' => compose_file),
        'docker', 'compose', 'config', '--quiet',
        unsetenv_others: true, chdir: repo_root.to_s
      )

      expect(status).to be_success, "docker compose config failed for a fresh clone:\n#{output}"
    end
  end
end
