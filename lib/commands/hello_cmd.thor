# frozen_string_literal: true

require 'commands/lar_city/cli/base_cmd'

class HelloCmd < LarCity::CLI::BaseCmd
  namespace 'demo'

  def self.exit_on_failure?
    true
  end

  desc 'hello', 'Say hello to [--name NAME]!'
  option :name,
         desc: 'Name to say hello to',
         type: :string,
         aliases: %w[-n --name],
         default: 'world',
         required: false
  def hello
    say "👋🏽 Hello, #{options[:name]}! #{detected_os_clause}", :magenta
  end

  no_commands do
    def detected_os_clause
      friendly_os_name = AppUtils.friendly_os_name
      return '' if friendly_os_name == :unsupported

      "You're running on #{human_friendly_os_names_map[friendly_os_name]} 💻"
    end
  end
end
