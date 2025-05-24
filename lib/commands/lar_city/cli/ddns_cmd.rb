# frozen_string_literal: true

require 'net/http'
require 'json'

module LarCity
  module CLI
    # Thor command for managing DNS records
    class DDNSCmd < Thor
      include Thor::Actions

      namespace :ddns

      desc 'update', 'Update DNS record with current public IP'
      option :token, type: :string, aliases: '-t', desc: 'DigitalOcean API token'
      option :domain, type: :string, aliases: '-d', required: true, desc: 'Domain name (e.g., example.com)'
      option :record, type: :string, aliases: '-r', default: '@', desc: 'Record name (e.g., @ or subdomain)'
      option :type, type: :string, aliases: '-y', default: 'A', desc: 'Record type (A, AAAA, etc.)'

      def update
        # Get the public IP
        public_ip = fetch_public_ip
        say "Current public IP: #{public_ip}", :green

        # Get API token from options or environment
        token = options[:token] || ENV['DIGITALOCEAN_TOKEN']
        unless token
          say 'Error: DigitalOcean API token not provided. Use --token or set DIGITALOCEAN_TOKEN environment variable.', :red
          exit 1
        end

        # Update the DNS record
        update_dns_record(token, options[:domain], options[:record], options[:type], public_ip)
      end

      no_commands do
        def fetch_public_ip
          # Try multiple services in case one is down
          services = [
            'https://api.ipify.org',
            'https://ifconfig.me/ip',
            'https://ipinfo.io/ip'
          ]

          services.each do |url|
            begin
              ip = Net::HTTP.get(URI(url)).strip
              # Basic IP validation
              if ip.match?(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
                return ip
              end
            rescue StandardError => e
              say "Failed to get IP from #{url}: #{e.message}", :yellow
              next
            end
          end

          say 'Error: Could not determine public IP address', :red
          exit 1
        end

        def update_dns_record(token, domain, record_name, record_type, ip_address)
          # Get domain records
          headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{token}",
          }

          # Get all domain records
          uri = URI("https://api.digitalocean.com/v2/domains/#{domain}/records")
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            request = Net::HTTP::Get.new(uri, headers)
            http.request(request)
          end

          unless response.is_a?(Net::HTTPSuccess)
            say "Error fetching DNS records: #{response.body}", :red
            exit 1
          end

          records = JSON.parse(response.body)['domain_records']

          # Find the record to update
          record = records.find do |r|
            r['type'] == record_type &&
            (record_name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == record_name)
          end

          if record
            # Update existing record
            uri = URI("https://api.digitalocean.com/v2/domains/#{domain}/records/#{record['id']}")
            data = { data: ip_address }.to_json

            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              request = Net::HTTP::Put.new(uri, headers)
              request.body = data
              http.request(request)
            end

            if response.is_a?(Net::HTTPSuccess)
              say "Successfully updated #{record_type} record #{record_name}.#{domain} to #{ip_address}", :green
            else
              say "Error updating DNS record: #{response.body}", :red
              exit 1
            end
          else
            # Create new record
            uri = URI("https://api.digitalocean.com/v2/domains/#{domain}/records")
            data = {
              type: record_type,
              name: (record_name == '@' ? nil : record_name),
              data: ip_address,
              ttl: 300,
            }.to_json

            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              request = Net::HTTP::Post.new(uri, headers)
              request.body = data
              http.request(request)
            end

            if response.is_a?(Net::HTTPSuccess)
              say "Successfully created #{record_type} record #{record_name}.#{domain} with IP #{ip_address}", :green
            else
              say "Error creating DNS record: #{response.body}", :red
              exit 1
            end
          end
        end
      end
    end
  end
end
