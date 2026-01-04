# frozen_string_literal: true

unless Rails.env.test?
  # Check for Curl
  unless system('which curl > /dev/null 2>&1')
    puts '🚫 Curl is not installed! Please install curl to continue.'
    exit(1)
  end

  # Check for git
  unless system('which git > /dev/null 2>&1')
    puts '🚫 Git is not installed! Please install git to continue.'
    exit(1)
  end
end
