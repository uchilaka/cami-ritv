# frozen_string_literal: true

require 'faraday'
require 'lib/lar_city/http_client'

module LarCity
  module CLI
    # Thor command for managing DNS records using DigitalOcean's API
    class DDNSCmd < Thor
      include Thor::Actions

      namespace :ddns

      desc 'update', 'Update DNS record with current public IP'
      option :token, type: :string, aliases: '-t', desc: 'DigitalOcean API token'
      option :domain, type: :string, aliases: '-d', required: true, desc: 'Domain name (e.g., example.com)'
      option :record, type: :string, aliases: '-r', default: '@', desc: 'Record name (e.g., @ or subdomain)'
      option :type, type: :string, aliases: '-y', default: 'A', desc: 'Record type (A, AAAA, etc.)'
      option :ttl, type: :numeric, default: 300, desc: 'Time to live in seconds (default: 300)'

      # Updates a DNS record with the current public IP address
      # @return [void]
      def update
        public_ip = fetch_public_ip
        say "Current public IP: #{public_ip}", :green

        token = options[:token] || ENV['DIGITALOCEAN_TOKEN']
        unless token
          say 'Error: DigitalOcean API token not provided. Use --token or set DIGITALOCEAN_TOKEN environment variable.', :red
          exit 1
        end

        update_dns_record(
          token: token,
          domain: options[:domain],
          record_name: options[:record],
          record_type: options[:type],
          ip_address: public_ip,
          ttl: options[:ttl].to_i
        )
      end

      no_commands do
        # Fetches the current public IP address by trying multiple services
        # @return [String] The public IP address
        # @raise [SystemExit] if no valid IP address can be determined
        def fetch_public_ip
          services = [
            'https://api.ipify.org',
            'https://ifconfig.me/ip',
            'https://ipinfo.io/ip'
          ]

          client = LarCity::HttpClient.client

          services.each do |url|
            begin
              response = client.get(url)
              ip = response.body.strip
              return ip if ip.match?(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
            rescue Faraday::Error => e
              say "Failed to get IP from #{url}: #{e.message}", :yellow
              next
            end
          end

          say 'Error: Could not determine public IP address', :red
          exit 1
        end

        # Updates or creates a DNS record in DigitalOcean
        # 
        # @param token [String] DigitalOcean API token
        # @param domain [String] Domain name
        # @param record_name [String] Record name (e.g., '@' for root, 'www' for subdomain)
        # @param record_type [String] Record type (A, AAAA, etc.)
        # @param ip_address [String] IP address to set
        # @param ttl [Integer] Time to live in seconds (default: 300)
        # @return [void]
        def update_dns_record(
          token:,
          domain:,
          record_name:,
          record_type: 'A',
          ip_address:,
          ttl: 300
        )
          client = LarCity::HttpClient.new_client
          client.headers['Authorization'] = "Bearer #{token}"

          begin
            # Get all domain records
            response = client.get("https://api.digitalocean.com/v2/domains/#{domain}/records")
            records = response.body['domain_records']

            # Find the record to update
            record = records.find do |r|
              r['type'] == record_type &&
              (record_name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == record_name)
            end

            if record
              # Update existing record
              client.put(
                "https://api.digitalocean.com/v2/domains/#{domain}/records/#{record['id']}",
                { 
                  data: ip_address,
                  ttl: ttl
                }.to_json
              )
              say "Successfully updated #{record_type} record #{record_name}.#{domain} to #{ip_address}", :green
            else
              # Create new record
              client.post(
                "https://api.digitalocean.com/v2/domains/#{domain}/records",
                {
                  type: record_type,
                  name: (record_name == '@' ? nil : record_name),
                  data: ip_address,
                  ttl: ttl
                }.to_json
              )
              say "Successfully created #{record_type} record #{record_name}.#{domain} with IP #{ip_address}", :green
            end
          rescue Faraday::Error => e
            say "Error communicating with DigitalOcean API: #{e.message}", :red
            say "Response: #{e.response[:body]}" if e.response
            exit 1
          end
        end
      end
    end
  end
end
