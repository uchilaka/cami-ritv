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

      EnvHelpers.define_class_options self
      OutputHelpers.define_class_options self

      class_option :user,
                   aliases: '-u',
                   required: true
      def ssh_into_nas_box
        with_interruption_rescue do
          ssh_command = ['ssh', "-p #{ssh_port}"]
          # Check for identity file from home directory - match the first one found
          # (this allows for different identity files on different machines)
          %W[id_rsa_#{user} id_rsa].any? do |key_name|
            potential_path = File.join(Dir.home, '.ssh', key_name)
            if File.exist?(potential_path)
              ssh_command << "-i #{potential_path}"
              say_highlight "Using SSH identity file at #{potential_path}" if verbose?
              true
            else
              false
            end
          end
          # Set user and target host
          say_info "Connecting to NAS box at #{target_host} as user '#{user}'..."
          ssh_command << (user.present? ? "#{user}@#{target_host}" : target_host)
          # TODO: Optionally set landing path on host
          # Execute the SSH command
          run(*ssh_command, inline: true)
        end
      end

      no_commands do
        def user
          options[:user]
        end

        def landing_path
          ENV.fetch('HOME_OFFICE_NAS_LANDING_PATH', '/volume1/docker')
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
