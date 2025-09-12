# frozen_string_literal: true

require 'lib/digital_ocean/api'

module LarCity
  module CLI
    # Thor command for managing DNS records using DigitalOcean's API
    class DDNSCmd < BaseCmd
      include Thor::Actions

      namespace :ddns

      def self.http_client(access_token:)
        new_client = ::LarCity::HttpClient.new_client
        new_client.headers['Authorization'] = "Bearer #{access_token}" if access_token.present?
        new_client
      end

      def self.set_dns_record_options
        option :access_token, type: :string, aliases: '-p', desc: 'DigitalOcean API token'
        option :domain, type: :string, required: true, desc: 'Domain name (e.g., example.com)'
        option :record, type: :string, aliases: '-r', default: '@', desc: 'Record name (e.g., @ or subdomain)'
        option :type, type: :string, aliases: '-t', default: 'A', desc: 'Record type (A, AAAA, etc.)'
        option :ttl, type: :numeric, default: 300, desc: 'Time to live in seconds (default: 300)'
      end

      desc 'cleanup', 'Cleanup retired DNS records'
      set_dns_record_options
      def cleanup
        domain = options[:domain]
        name = [options[:record], options[:domain]].join('.')
        records = get_records(domain:, name:, type: options[:type])
        say_info "Found #{records&.size} records for #{name} on #{domain}"
      end

      desc 'upsert', 'Update DNS record with current public IP'
      set_dns_record_options
      def upsert
        public_ip = fetch_public_ip
        say "Current public IP: #{public_ip}", :green

        upsert_dns_record(
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
          services = %w[
            https://api.ipify.org
            https://ifconfig.me/ip
            https://ipinfo.io/ip
          ]

          client = LarCity::HttpClient.client

          services.each do |url|
            response = client.get(url)
            ip = response.body.strip
            return ip if ip.match?(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
          rescue Faraday::Error => e
            say "Failed to get IP from #{url}: #{e.message}", :yellow
            next
          end

          say 'Error: Could not determine public IP address', :red
          exit 1
        end

        def get_records(domain:, name:, type: 'A')
          query_string = { name:, type: }.to_query
          response = client.get("https://api.digitalocean.com/v2/domains/#{domain}/records?#{query_string}")
          response.body['domain_records']
        rescue Faraday::Error => e
          say "Error communicating with DigitalOcean API: #{e.message}", :red
          say "Response: #{e.response[:body]}" if e.response
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
        def upsert_dns_record(
          domain:,
          record_name:,
          ip_address:,
          record_type: 'A',
          ttl: 300
        )
          # Get all domain records
          response = client.get("https://api.digitalocean.com/v2/domains/#{domain}/records")
          records = response.body['domain_records']

          # Find the record to update
          record = records&.find do |r|
            r['type'] == record_type &&
              (record_name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == record_name)
          end

          if record
            # Update existing record
            client.put(
              "https://api.digitalocean.com/v2/domains/#{domain}/records/#{record['id']}",
              {
                data: ip_address,
                ttl:,
              }.to_json
            )
            record_details = record_info(name: record_name, domain:, type: record_type, content: ip_address)
            say "Successfully updated #{record_details}", :green
          else
            # Create new record
            client.post(
              "https://api.digitalocean.com/v2/domains/#{domain}/records",
              {
                type: record_type,
                name: (record_name == '@' ? nil : record_name),
                data: ip_address,
                ttl:,
              }.to_json
            )
            say "Successfully created #{record_type} record #{record_name}.#{domain} with IP #{ip_address}", :green
          end
        rescue Faraday::Error => e
          say "Error communicating with DigitalOcean API: #{e.message}", :red
          say "Response: #{e.response[:body]}" if e.response
          exit 1
        end

        def access_token
          @access_token ||= options[:access_token]
        end
      end

      private

      def record_info(name:, domain:, content:, type: 'A')
        "\"#{type}\" record with name \"#{name}\" on #{domain} -> #{content}"
      end

      def client(token: access_token)
        if token.blank?
          @client ||= DigitalOcean::API.http_client
        else
          @client = DigitalOcean::API.http_client(access_token: token)
        end
      end
    end
  end
end
