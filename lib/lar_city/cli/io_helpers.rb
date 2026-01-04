# frozen_string_literal: true

require_relative 'utils/class_helpers'
require_relative 'output_helpers'

module LarCity
  module CLI
    module IoHelpers
      extend Utils::ClassHelpers

      def self.included(base)
        require_thor_options_support!(base)

        base.include OutputHelpers
        base.include InstanceMethods
      end

      def self.define_auth_config_path_option(thor_class, class_option: false)
        option_params = [
          :auth_config_path,
          type: :string,
          aliases: '-o',
          desc: 'The directory to store the htpasswd file',
          default: 'config/httpd',
        ]
        if class_option
          thor_class.class_option(*option_params)
        else
          thor_class.option(*option_params)
        end
      end

      module InstanceMethods
        def auth_dir_mount_source
          @auth_dir_mount_source ||=
            begin
              auth_dir =
                if auth_config_path.start_with?('/')
                  auth_config_path
                else
                  Rails.root.join(auth_config_path).to_s
                end

              rel_path = auth_dir.gsub(/^#{Rails.root}/, '').split('/').reject(&:blank?)
              rel_path << 'auth' unless rel_path.last == 'auth'
              auth_dir = Rails.root.join(*rel_path).to_s

              if Dir.exist?(auth_dir)
                say_status :exist, "directory: #{auth_dir}" if verbose?
              elsif dry_run?
                say_highlight "Dry-run: Would have created directory #{auth_dir}"
              else
                say_status :create, "directory: #{auth_dir}" if verbose?
                FileUtils.mkdir_p(auth_dir, noop: pretend?, verbose: verbose?)
              end

              auth_dir
            end
        end

        protected

        def auth_config_path
          options[:auth_config_path]
        end
      end
    end
  end
end
