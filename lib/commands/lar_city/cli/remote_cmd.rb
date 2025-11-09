# frozen_string_literal: true

module LarCity
  module CLI
    class RemoteCmd < Thor::Group
      namespace 'remote'

      no_commands do
        include OperatingSystemDetectable
        include EnvHelpers
        include Runnable
      end

      class_option :user,
                   aliases: '-u',
                   required: true
      def ssh_into_nas_box
        with_interruption_rescue do
          ssh_command = ['ssh', "#{user}@#{target_host}", "-p #{ssh_port}"]
          say_info "Connecting to NAS box at #{target_host} as user '#{user}'..."
          run(*ssh_command, inline: true)
        end
      end

      no_commands do
        def user
          options[:user]
        end

        def target_host
          ENV.fetch('HOME_OFFICE_NAS_HOST', 'ho.larcity.tech')
        end

        def ssh_port
          ENV.fetch('HOME_OFFICE_NAS_SSH_PORT', '4242')
        end
      end
    end
  end
end
