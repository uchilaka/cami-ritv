# frozen_string_literal: true

require 'commands/lar_city/cli/base_cmd'
require 'awesome_print'

module Fixtures
  module Zoho
    class Serverinfo < LarCity::CLI::BaseCmd
      namespace 'zoho:serverinfo'

      method_option :region,
                    type: :string,
                    aliases: '-r',
                    desc: 'Region to load server info for (capitalized, alpha2 by ISO 3166-1)',
                    enum: %w[US EU IN AU JP UK CA SA],
                    default: 'US'
      desc 'load', 'Load server info from Zoho'
      def load
        # Baseline: Check for US region server config for CRM auth
        us_serverinfo_for_auth = lookup(region_alpha2:)
        if us_serverinfo_for_auth.present?
          say_success 'Found metadata!'
          ap us_serverinfo_for_auth.serializable_hash
          return
        end

        result = ::Zoho::UpdateServerinfoMetadata.call
        if result.success?
          say_success 'Metadata loaded successfully!'
        else
          say_error 'Failed to load metadata!'
          say_error result.error_message
          return
        end

        # Validation: Check for US region server config for CRM auth
        us_serverinfo_for_auth = lookup(region_alpha2:)
        if us_serverinfo_for_auth.blank?
          say_error 'Metadata not found!'
          say_error 'Please check your network connection and try again.'
          return
        end

        say_success '(Validation) found metadata'
        ap us_serverinfo_for_auth.serializable_hash
      end

      no_commands do
        def region_alpha2_or(default_region:)
          if region_alpha2.blank?
            say_warning 'Region not specified. Using default region.'
            return default_region
          end

          unless %w[US EU IN AU JP UK CA SA].include?(region_alpha2)
            say_error 'Invalid region specified. Using default region.'
            return default_region
          end

          region_alpha2
        end

        def region_alpha2
          options[:region].to_s.strip.upcase
        end

        def lookup(region_alpha2:)
          ::Zoho::OauthServerinfo.having_region_alpha2(region_alpha2).first
        end
      end
    end
  end
end
