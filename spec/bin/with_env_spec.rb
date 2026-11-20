# frozen_string_literal: true

# Deliberately NOT rails_helper: bin/with-env is a shell script, and these examples run it
# against a scratch git repo. Booting Rails would only add a database dependency.
# spec_helper is loaded for us by .rspec.
require 'fileutils'
require 'open3'
require 'pathname'
require 'tmpdir'

RSpec.describe 'bin/with-env' do
  let(:script) { Pathname.new(__dir__).join('../../bin/with-env').expand_path }

  # A throwaway checkout: with-env finds its env files through `git rev-parse`, so the
  # scratch dir must be a repo for the script to look there rather than at this one.
  around do |example|
    Dir.mktmpdir('with-env') do |dir|
      @root = Pathname.new(dir)
      system('git', 'init', '-q', dir, exception: true)
      example.run
    end
  end

  def run_with_env(*args, shell: 'bash')
    env = { 'RUBY_ENV' => 'development' }
    Open3.capture3(env, shell, script.to_s, *args, chdir: @root.to_s)
  end

  it 'selects the target environment' do
    out, err, status = run_with_env('test', 'env')

    expect(status).to be_success, err
    expect(out).to include("RUBY_ENV=test\n", "RAILS_ENV=test\n")
  end

  it 'drops a variable the current environment file declares' do
    @root.join('.env.development').write("export LEAKY_KEY=dev\n")

    out, err, status = Open3.capture3(
      { 'RUBY_ENV' => 'development', 'LEAKY_KEY' => 'dev' },
      'bash', script.to_s, 'test', 'env',
      chdir: @root.to_s
    )

    expect(status).to be_success, err
    expect(out).not_to include('LEAKY_KEY=')
  end

  # git-crypt's locked files start with the bytes "\0GITCRYPT". Bash can't hold a NUL in a
  # string, so a check written as `[[ $(head -c 9 f) == $'\0GITCRYPT' ]]` compares
  # "GITCRYPT" against "" and never matches -- the warning this script promises would
  # never print, and isolation would degrade silently.
  it 'warns that isolation is degraded when an env file is git-crypt locked' do
    @root.join('.env.development').binwrite("\0GITCRYPT\0\x01\x02ciphertext")

    _out, err, status = run_with_env('test', 'true')

    expect(status).to be_success, err
    expect(err).to include('.env.development is git-crypt locked')
    expect(err).to include('Environment isolation is DEGRADED')
  end

  # With no env files to read there is nothing to unset. `"${arr[@]}"` on an empty array
  # is an unbound-variable error under `set -u` before bash 4.4 -- which is macOS's
  # /bin/bash, the one `#!/usr/bin/env bash` finds when Homebrew bash isn't on PATH.
  it 'runs when there is nothing to unset, under the system bash too' do
    shells = ['bash', '/bin/bash'].select { |sh| sh == 'bash' || File.executable?(sh) }

    shells.each do |sh|
      _out, err, status = run_with_env('test', 'true', shell: sh)
      expect(status).to be_success, "#{sh}: #{err}"
    end
  end

  it 'prints usage and exits 64 without a command' do
    _out, err, status = run_with_env('test')

    expect(status.exitstatus).to eq(64)
    expect(err).to include('usage: bin/with-env')
  end
end
