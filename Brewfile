# frozen_string_literal: true

require 'fileutils'

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: false

puts "Environment: #{ENV.fetch('RAILS_ENV', '<N/A>')}"

# Environment specific dependencies
if %w[staging production].include?(ENV['RAILS_ENV'])
  brew 'mise'
  brew 'certbot'
else
  # Dev & anonymous environments
  brew 'gh'
  # Direnv will be managed as a mise dependency instead
  #brew 'direnv'
  brew 'goreman'

  # Skip these specifically in test environments
  unless %w[ci test].include?(ENV['RAILS_ENV'])
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
  end
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

cask 'keepassxc'
cask 'claude'
cask 'notion'
cask '1password'

unless %w[ci test production].include?(ENV['RAILS_ENV'])
  cask 'insomnia'
  cask 'discord'
  cask 'slack'
  cask 'whatsapp'
  cask 'signal'
  begin
    # TODO: Turned off require_sha to get Messenger installed... too risky?
    cask 'messenger'
  rescue => _e
    if File.exist?('/Applications/Messenger.app')
      puts 'Found Messenger installed 🎊 - skipping Messenger installation'
    end
  end
end
