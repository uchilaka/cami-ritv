# frozen_string_literal: true

require 'fileutils'

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: true

puts "Environment: #{ENV.fetch('RAILS_ENV', '<N/A>')}"

# Environment specific dependencies
if %w[staging production].include?(ENV['RAILS_ENV'])
  brew 'mise'
else
  # Dev & anonymous environments
  brew 'gh'
  brew 'asdf'
  brew 'direnv'

  # Skip these specifically in test environments
  unless %w[ci test].include?(ENV['RAILS_ENV'])
    brew 'foreman' if OS.mac?
    brew 'tree' if OS.mac?
    brew 'ruby-build'
    # TODO: what's the overlap between this and gnutls?
    brew 'coreutils'
    brew 'gnupg'
    brew 'git-crypt'

    if File.exist?('/Applications/RubyMine.app')
      puts 'Found RubyMine installed 🥳 - skipping RubyMine installation'
    elsif ENV['VISUAL'] == 'rubymine' || ENV['EDITOR'] == 'rubymine'
      cask 'rubymine'
    else
      cask 'visual-studio-code'
      cask 'windsurf'
    end

    # FYI: Brew cask only works on macOS
    if File.exist?('/usr/local/bin/docker')
      puts 'Found Docker installed 🥳 - skipping docker installation'
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
end
