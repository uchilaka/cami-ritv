# frozen_string_literal: true

require 'fileutils'

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: true

# brew install
brew 'foreman'
brew 'tree'
brew 'direnv'
brew 'ruby-build'
brew 'asdf'
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
  cask 'ngrok'
  brew 'pgadmin4'
  brew 'pinentry-mac'
end

if File.exist?('/Applications/RubyMine.app')
  puts 'Found RubyMine installed 🥳 - skipping RubyMine installation'
elsif ENV['VISUAL'] == 'rubymine' || ENV['EDITOR'] == 'rubymine'
  cask 'rubymine'
else
  cask 'visual-studio-code'
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
