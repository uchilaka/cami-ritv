# frozen_string_literal: true

require 'fileutils'
require_relative 'base_cmd'

module LarCity
  module CLI
    class DatakitCmd < BaseCmd
      namespace 'datakit'

      # TODO: Add support for managing & processing target files in remote storage buckets (e.g. S3)
      desc 'sanitize', 'Sanitize a data file'
      option :file,
             desc: 'The file to sanitize',
             type: :string,
             aliases: '-f',
             required: true
      def sanitize
        raise Errors::UnsupportedOSError, 'Unsupported OS' unless mac? || linux?

        input_file = options[:file]
        input_file = Rails.root.join(input_file) unless input_file.start_with?('/')
        raise Thor::Error, 'Invalid file' unless File.exist?(input_file)
        raise Thor::Error, 'Unsupported file type' unless File.extname(input_file) == '.json'

        sanitized_data = PIISanitizer.sanitize(JSON.parse(File.read(input_file)))
        # Make output path the same as the input file
        output_path = File.dirname(input_file)
        output_file = "#{output_path}/#{File.basename(input_file, '.*')}_sanitized.json"

        write_msg = []
        write_msg << '(Dry-run)' if dry_run?
        write_msg << "Will write sanitized data to #{output_file}"
        say write_msg.join(' '), Color::YELLOW
        File.write(output_file, sanitized_data) unless dry_run?
      end
    end
  end
end
