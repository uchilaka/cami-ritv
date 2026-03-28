# frozen_string_literal: true

module DigitalOcean
  class Utils
    class << self
      def app_id!
        ENV.fetch('DO_APP_ID', credentials!.app_id)
      end

      def access_token!
        %w[DO_ACCESS_TOKEN DIGITALOCEAN_ACCESS_TOKEN].find do |env_key|
          (@access_token ||= ENV.fetch(env_key, nil)).present?
        end
        @access_token ||= credentials!.access_token
      end

      private

      def credentials!
        Rails.application.credentials.digitalocean!
      end
    end
  end
end
