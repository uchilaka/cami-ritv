# frozen_string_literal: true

require 'lib/digital_ocean'

module LarCity
  module CLI
    # Thor command for managing DNS records using DigitalOcean's API
    class DDNSCmd < BaseCmd
      include Thor::Actions

      namespace :ddns

      def self.set_dns_record_options(required: [])
        option :access_token, type: :string, aliases: '-p', desc: 'DigitalOcean API token'
        option :domain,
               desc: 'Domain name (e.g., example.com)',
               type: :string,
               required: true
        option :record,
               desc: 'Record name (e.g., @ or subdomain)',
               type: :string,
               aliases: %w[-r -n],
               default: required.include?(:record) ? nil : '@',
               required: required.include?(:record)
        option :type,
               desc: 'Record type (A, AAAA, etc.)',
               type: :string,
               aliases: '-t',
               default: required.include?(:type) ? nil : 'A',
               required: required.include?(:type)
        option :ttl,
               desc: 'Time to live in seconds (default: 300)',
               type: :numeric,
               default: 300
      end

      desc 'cleanup', 'Cleanup retired DNS records'
      set_dns_record_options(required: %i[record type])
      option :batch_size,
             desc: 'Number of records to be processed',
             type: :numeric,
             default: 25
      def cleanup
        batch_size = options[:batch_size].to_i
        with_interruption_rescue do
          raise ArgumentError, 'Batch size must be <= 200' if batch_size > 200

          domain = options[:domain]
          name = [options[:record], options[:domain]].join('.')
          record_type = options[:type]
          with_http_error_rescue do
            records = []
            per_page = [batch_size, 100].min
            page = 1
            # Iterate over the pages and fetch records as long as a result is returned
            while (next_records = get_records(domain:, name:, type: record_type, access_token:, page:, per_page:))&.any?
              # Exit while loop if we exceed the batch size
              break if records.size >= batch_size

              records += next_records
              # say_info "Found #{records.size} records for #{name} on #{domain} (page #{page})"
              page += 1
            end

            verified_count = 0
            if records&.any?
              say_info "Found #{records.size} records for #{name} on #{domain}"

              records.each_with_index do |record, index|
                backoff_seconds = (index + 1) * 5
                record_details =
                  record_info(name: record['name'], domain:, type: record['type'], content: record['data'])
                next unless cleanup_hit?(domain:, **record.symbolize_keys.slice(:name, :type))

                verified_count += 1
                say "Enqueueing deletion for #{record_details}", :yellow
                DigitalOcean::DeleteDomainRecordJob
                  .set(wait: backoff_seconds.seconds)
                  .perform_later(record['id'], domain:, access_token:, pretend: dry_run?)
              end

              say_info "Enqueued #{verified_count} of #{records.size} records for #{name} on #{domain}"
            else
              say_warning "No records found for #{name} on #{domain}"
            end
          end
        end
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
        delegate :get_records, :v2_endpoint, to: DigitalOcean::API

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

        # Updates or creates a DNS record in DigitalOcean
        #
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
          with_http_error_rescue('Error communicating with DigitalOcean API') do
            # Get all domain records
            response = client.get(v2_endpoint("domains/#{domain}/records"))
            records = response.body['domain_records']

            # Find the record to update
            record = records&.find do |r|
              r['type'] == record_type &&
                (record_name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == record_name)
            end

            if record
              # Update existing record
              client.patch(
                v2_endpoint("domains/#{domain}/records/#{record['id']}"),
                {
                  type: record_type,
                  data: ip_address,
                  ttl:,
                }.to_json
              )
              record_details = record_info(name: record_name, domain:, type: record_type, content: ip_address)
              say "Successfully updated #{record_details}", :green
            else
              # Create new record
              client.post(
                v2_endpoint("domains/#{domain}/records"),
                {
                  type: record_type,
                  name: (record_name == '@' ? nil : record_name),
                  data: ip_address,
                  ttl:,
                }.to_json
              )
              say "Successfully created #{record_type} record #{record_name}.#{domain} with IP #{ip_address}", :green
            end
          end
        end

        def access_token
          @access_token ||= options[:access_token]
        end
      end

      private

      def cleanup_hit?(domain:, name:, type:)
        domain == options[:domain] && name == options[:record] && type == options[:type]
      end

      def with_http_error_rescue(caption = 'An HTTP Error occurred', &)
        yield
      rescue Faraday::Error => e
        say "#{caption}: #{e.message}", :red
        say "Response: #{e.response[:body]}" if e.response
        exit 1
      end

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
