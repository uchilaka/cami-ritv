# frozen_string_literal: true

require 'fileutils'

current_env = `echo $RAILS_ENV`.strip
rails_env = ENV.fetch('RAILS_ENV', current_env)

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: false

puts "Environment: #{rails_env.blank? ? 'NOT SET' : rails_env}"

# Dev & anonymous environments
brew 'gh'
# Direnv will be managed as a mise dependency instead
# brew 'direnv'
brew 'goreman'

# Skip these specifically in test environments
unless %w[ci test].include?(rails_env)
  brew 'tree' if OS.mac?
  brew 'ruby-build'
  # TODO: what's the overlap between this and gnutls?
  brew 'coreutils'
  brew 'gnupg'
  brew 'git-crypt'

  if File.exist?('/Applications/RubyMine.app')
    puts 'Found RubyMine installed 🎊 - skipping RubyMine installation'
  elsif ENV['VISUAL'] == 'rubymine' || ENV['EDITOR'] == 'rubymine'
    cask 'rubymine'
  else
    cask 'visual-studio-code'
    # cask 'windsurf'
  end

  # FYI: Brew cask only works on macOS
  if File.exist?('/usr/local/bin/docker')
    puts 'Found Docker installed 🎊 - skipping docker installation'
  elsif OS.mac?
    puts 'Setting up Rancher Desktop (an open source Docker Desktop alternative)'
    cask 'rancher'
  end

brew 'yq'
brew 'vips'

# install only on specified OS
if OS.mac?
  brew 'gnutls'
  # NOTE: For info on setting this up (required to use `git crypt <...>`), run:
  #   brew info pinentry-mac
  brew 'pinentry-mac'
  cask 'ngrok'
  cask 'pgadmin4'
end

if rails_env == 'lab'
  brew 'certbot'
end

if rails_env == 'development'
  cask 'keepassxc'
  cask 'claude'
  cask '1password'
  cask 'insomnia'
end

if %w[development lab].include?(rails_env)
  tap 'protonpass/tap'
  brew 'pass-cli'
  brew 'render'
  cask 'gcloud-cli'
  cask 'notion'
  cask 'discord'
  cask 'slack'
  cask 'whatsapp'
  cask 'signal'
  cask 'moom'
  cask 'stats'
  cask 'iterm2'
  begin
    # TODO: Turned off require_sha to get Messenger installed... too risky?
    cask 'messenger'
  rescue StandardError => _e
    puts 'Found Messenger installed 🎊 - skipping Messenger installation' if File.exist?('/Applications/Messenger.app')
  end
end
