# frozen_string_literal: true

def load_lib_script(*script_rel_path_parts, ext: 'rb')
  script_rel_path = script_rel_path_parts.compact.join('/')
  load "#{Dir.pwd}/lib/#{script_rel_path}.#{ext}"
end

def load_cli_script(script_name)
  load_lib_script('commands', 'lar_city_cli', script_name, ext:)
end

def random_invoice_vendor_record_id(vendor: 'paypal')
  [
    vendor == 'paypal' ? "INV#{SecureRandom.random_number(9)}" : SecureRandom.hex(4),
    SecureRandom.alphanumeric(4),
    SecureRandom.alphanumeric(4),
    SecureRandom.alphanumeric(4)
  ].join('-').upcase
end

def random_invoice_number(year: Time.now.year)
  random_number = rand(1000..9999)
  "INV#{year}-#{random_number.to_s.rjust(4, '0')}"
end
