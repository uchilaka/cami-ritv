# frozen_string_literal: true

def load_thor_command(*rel_path, ext: 'thor')
  basename = rel_path.pop
  raise ArgumentError if basename.blank?

  code_file =
    if File.extname(basename).blank?
      ext ||= File.extname(basename).sub(%r{^\.}, '')
      "#{basename}.#{ext}"
    else
      basename
    end
  load Rails.root.join(*rel_path, code_file)
end
