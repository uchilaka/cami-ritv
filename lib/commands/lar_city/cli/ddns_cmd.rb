# frozen_string_literal: true

require 'lib/digital_ocean'
require 'lib/commands/lar_city/cli/base_cmd'
require 'lar_city/cli/control_flow_helpers'

module LarCity
  module CLI
    # Thor command for managing DNS records using DigitalOcean's API
    class DDNSCmd < BaseCmd
      # TODO: What was this included for? Review:
      #   https://github.com/uchilaka/cami-ritv/commit/ffdebd5898507d6d3c06836dfbd0484cbde79fb1#diff-6e6f348d1586f6d47928f4d11b7cb818e384665d94580db5c6ef24e5b2722a2f
      # include Thor::Actions

      no_commands do
        include IntegrationHelpers
        include ControlFlowHelpers
      end

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
                  record_info(id: record['id'], name: record['name'], domain:, type: record['type'], content: record['data'])
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

      desc 'prune', 'Prune dirty DNS records that have multiple records for the same name and type'
      set_dns_record_options(required: %i[record type])
      option :batch_size,
             desc: 'Number of records to be processed',
             type: :numeric,
             default: 25
      def prune
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
            if records.size == 1
              say_info "Only 1 record found for #{name} on #{domain}. No pruning needed."
              return
            end

            if records.any?
              say_warning "Found #{records.size} records for #{name} on #{domain}"

              records[1..].each_with_index do |record, index|
                backoff_seconds = (index + 1) * 5
                record_details =
                  record_info(id: record['id'], name: record['name'], domain:, type: record['type'], content: record['data'])
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

      desc 'update', 'Update DNS record via ddclient with current public IP'
      set_dns_record_options
      def update
        public_ip = fetch_public_ip
        say_debug "Current public IP: #{public_ip}"
        name, domain, record_type =
          options.values_at :record, :domain, :type
        require_doctl_cli!

        # Check for record
        fqdn = [name, domain].join('.')
        matching_records = filter_records_by(name:, type: record_type)
        say_debug JSON.pretty_generate(matching_records) unless matching_records.size > 100
        unless matching_records.size == 1
          say_warning <<~FIX_ASK
            ⚠️ Your task returned #{tally(matching_records, 'record')} found for #{fqdn}. \
            You need to have exactly 1 record for ddclient to work properly. \
            Please review the records and confirm that you want to proceed \
            with updating the record(s) for #{fqdn}.

            To cleanup dirty records, run `lx-cli ddns:prune` before \
            retrying this command.
          FIX_ASK

          return
        end

        if matching_records.blank?
          say_warning <<~FIX_ASK
            ⚠️ No records found for #{fqdn}. You need to have exactly 1 record for ddclient to work properly. \
            Please create a record for #{fqdn} with the desired IP address.
          FIX_ASK
          return
        end

        # Continue if exactly 1 record is returned
        say_success "Found a matching record for #{fqdn}"

        record = matching_records.first
        update_cmd = [
          'doctl compute domain records update',
          domain,
          "--access-token #{DigitalOcean::Utils.access_token!}",
          "--record-id #{record['id']}",
          "--record-name #{record['name']}",
          "--record-type #{record_type}",
          "--record-data #{public_ip}"
        ]
        update_cmd << '--verbose' if verbose?
        run(*update_cmd, inline: true)
      end

      no_commands do
        delegate :get_records, :v2_endpoint, to: DigitalOcean::API

        def build_ddclient_config(record_id:)
          hostname = [options[:record], options[:domain]].join('.')
          <<~CONF
            # Configuration file for ddclient.
            #
            # Daemon mode for periodic updates
            daemon=300
            syslog=yes

            # Method to determine the public IP address
            use=web, web=checkip.dynu.com/

            # DigitalOcean details
            protocol=digitalocean
            server=api.digitalocean.com
            login=#{options[:domain]}
            password=#{DigitalOcean::Utils.access_token!}

            # Hostname and record ID to update
            #{hostname}, record_id=#{record_id}
          CONF
        end

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

            if record.present? && record['data'] == ip_address
              record_details = record_info(name: record_name, domain:, type: record_type, content: ip_address)
              say "No update needed for #{record_details}", :green
              return
            end

            record_details = record_info(name: record_name, domain:, type: record_type, content: ip_address)

            # TODO: Implement Dns::Name and Dns::Record records in the database and cross-reference
            #   before deleting any records to prevent duplicating records or deleting records that
            #   are not managed by this tool.
            # TODO: IF a record is inconsistent with the desired state, we should:
            #   - FIRST check if the record is managed by this tool (e.g., by checking for a specific tag or metadata)
            #   - THEN, if the record is managed by this tool, we should update it to match the desired state rather
            #     than deleting and recreating it, to preserve any record-specific settings such as TTL or priority
            #     that may be in place.
            # TODO: Investigate why duplicate DigitalOcean records are being created and implement safeguards
            #   to prevent this from happening, such as:
            #    - Implementing a check to see if a record with the same name and type already exists before creating
            #      a new record, and updating the existing record instead of creating a duplicate.
            #    - Maintain a local cache or database of managed records to cross-reference before making API calls,
            #      ensuring that we only modify records that are under our management and avoid creating duplicates.
            #    - Maintain a cleanup routine that identifies and removes duplicate records that may have been created
            if record.present?
              # Update existing record
              resource_url = v2_endpoint("domains/#{domain}/records/#{record['id']}")
              payload = { data: ip_address, type: record_type, ttl: }
              if dry_run?
                say "Dry-run: Would have updated #{record_details}", :magenta
                return
              end

              say "Updating existing record at #{resource_url}", :yellow if verbose?
              client.patch(resource_url, payload.to_json)
              say "Successfully updated #{record_details}", :green
            else
              resource_url = v2_endpoint("domains/#{domain}/records")
              payload = { data: ip_address, name: (record_name == '@' ? nil : record_name), type: record_type, ttl: }
              if dry_run?
                say "Dry-run: Would have created #{record_details}", :magenta
                return
              end

              say "Creating new record at #{resource_url}", :yellow if verbose?
              # Create new record
              client.post(resource_url, payload.to_json)
              say "Successfully created #{record_type} record #{record_name}.#{domain} with IP #{ip_address}", :green
            end
          end
        end

        def domain_records
          @domain_records ||= list_records(domain: options[:domain])
        end

        def list_records(domain:)
          require_doctl_cli!

          list_cmd = [
            'doctl compute domain records list',
            domain,
            "--access-token #{DigitalOcean::Utils.access_token!}",
            '--output json'
          ]
          list_cmd << "--verbose" if verbose?
          JSON.parse(run(*list_cmd, eval: true, mock_return: '[]', inline: true))
        end

        def access_token
          @access_token ||= options[:access_token]
        end
      end

      private

      def filter_records_by(name:, type:)
        (domain_records || []).filter do |r|
          r['type'] == type &&
            (name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == name)
        end
      end

      def find_record_by(name:, type:)
        (domain_records || []).find do |r|
          r['type'] == type &&
            (name == '@' ? r['name'].nil? || r['name'].empty? : r['name'] == name)
        end
      end

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

      def record_info(name:, domain:, content:, type: 'A', id: nil)
        "\"#{type}\" record #{id || ''} with name \"#{name}\" on #{domain} -> #{content}"
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
