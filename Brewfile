# frozen_string_literal: true

require 'fileutils'

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: true

# brew install
brew 'foreman'
brew 'tree'
brew 'ruby-build'
brew 'coreutils'
brew 'gnupg'
brew 'git-crypt'
brew 'yq'
brew 'vips'

# install only on specified OS
if OS.mac?
  brew 'tree'
  brew 'gnutls'
  brew 'foreman'
  brew 'pinentry-mac'
  cask 'ngrok'
  cask 'pgadmin4'
end

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
cask 'keepassxc'
cask 'claude'
cask 'notion'
cask '1password'

unless ENV['RAILS_ENV'] == 'production'
  cask 'insomnia'
  cask 'discord'
  cask 'slack'
  cask 'whatsapp'
end

# Environment specific dependencies
if %w[staging production].include?(ENV['RAILS_ENV'])
  brew 'mise'
elsif %w[development].include?(ENV['RAILS_ENV'])
  brew 'asdf'
  brew 'direnv'
end
