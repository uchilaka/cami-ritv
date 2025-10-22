# frozen_string_literal: true

require_relative 'base_cmd'

module LarCity
  module CLI
    class SecretsCmd < BaseCmd
      namespace 'secrets'

      desc 'gpg-keys', 'List GPG keys in the system'
      def gpg_keys
        run 'gpg --list-secret-keys --keyid-format LONG'
      end

      desc 'edit', 'Manage the secrets in the environment credentials file'
      option :editor,
             type: :string,
             aliases: '--ide',
             desc: 'Editor to use',
             enum: %w[nano code rubymine],
             default: 'rubymine',
             required: true
      def edit
        executable = Rails.root.join('bin', 'rails')
        run "EDITOR=\"#{editor} --wait\"",
            "bundle exec #{executable} credentials:edit",
            "--environment=#{environment}"
      end

      # TODO: Add interactive :history command to peek into backup credential files
      desc 'backup', 'Backup an environment credentials file'
      long_desc <<~DESC
        Backup an environment credentials file. The backup file is saved
        in the config/credentials directory.

        This command supports the --environment option to specify the
        environment credentials file to backup. These files will also be
        saved with a timestamp in the filename and ignored when committing
        changes to source control.
      DESC
      option :git_crypt,
             type: :boolean,
             default: false
      def backup
        if options[:git_crypt]
          source_file = Rails.root.join('.git', 'git-crypt', 'keys', 'default').to_s
          secrets_path = Rails.root.join('config', 'secrets', timestamp).to_s
          backup_file = "#{secrets_path}/git-crypt.key"
          if File.exist?(source_file)
            say "Found git-crypt key at #{source_file}", Color::GREEN
            say "Backing up git-crypt key to #{backup_file}", Color::YELLOW
            FileUtils.mkdir_p(secrets_path, verbose: verbose?) unless dry_run?
            FileUtils.cp(source_file, backup_file, verbose: verbose?) unless dry_run?
          else
            warning_msg = <<~MSG
              *************************************************************************
              *********** WARNING: No git-crypt key found in this repository **********
              *************************************************************************
            MSG
            say warning_msg, Color::RED
            no_secret_file_msg = <<~MSG
              Location(s) checked for git-crypt key:
               |- #{source_file}

              To backup the git-crypt key, you must have initialized git-crypt.
              Run `git-crypt unlock /path/to/key` to initialize git-crypt. Check out
              the git-crypt documentation for more information:
              https://github.com/AGWA/git-crypt.

              To access shared secrets in this repository, you will need to be added
              to the git-crypt keychain. This will require setting up a GPG key against
              your GitHub account. Check out this guide for more information:
              https://bit.ly/gh-new-gpg-key

              Contact your Team Lead or a Staff Engineer for assistance.
            MSG
            say no_secret_file_msg
          end
        else
          backup_file = Rails.root.join('config', 'credentials', "#{environment}--#{timestamp}.yml.enc")
          FileUtils.cp(credentials_file, backup_file, verbose: verbose?) unless dry_run?

          backup_msg = []
          backup_msg << '(Dry-run)' if dry_run?
          backup_msg << "Backed up #{credentials_file} to #{backup_file}"
          say backup_msg.join(' '), Color::GREEN
        end
      end

      desc 'print_key', 'Print the contents of an input key file as a string'
      long_desc <<~DESC
        Print the contents of an input key file as a string. This is useful for copying the contents of a key file.

        Example:
          $ bin/thor lx-cli:secrets:print_key --key-file ~/.ssh/id_rsa
      DESC
      option :keyfile,
             type: :string,
             aliases: %w[-i --key-file],
             desc: 'Key file to print',
             required: true
      def print_key
        file_name = options[:keyfile].gsub(/^~/, Dir.home)

        unless File.exist?(file_name)
          raise ActiveStorage::FileNotFoundError,
                "Key file not found: #{file_name}"
        end

        key_data = File.read(file_name)
        puts key_data.dump
      rescue ActiveStorage::FileNotFoundError => error
        puts error
      end

      private

      def timestamp(style: :url_safe)
        case style
        when :url_safe
          Time.now.strftime('%Y-%m-%dT%H%M%S')
        else
          Time.now.iso8601
        end
      end

      def rubymine?
        system('which rubymine')
      end

      def vscode?
        system('which code')
      end

      def environment
        @environment = options[:environment]
        @environment = Rails.env if @environment.blank?
        @environment
      end

      def credentials_file
        Rails.root.join('config', 'credentials', "#{environment}.yml.enc")
      end

      def editor
        @editor ||= selected_or_default_editor
      end

      def detected_editor
        @detected_editor ||=
          if rubymine?
            'rubymine'
          else
            vscode? ? 'code' : 'nano'
          end
      end

      def selected_or_default_editor
        options[:editor] || ENV.fetch('EDITOR', detected_editor)
      end
    end
  end
end
