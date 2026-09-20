# frozen_string_literal: true

require 'uri'

# Decides which requests a browser-driven system spec may make.
#
# Browser traffic is outside VCR's reach -- VCR hooks the Ruby HTTP stack, not the browser --
# so this is the only thing keeping system specs off the public internet. Fabricated records
# carry external URLs (Faker::Avatar.image returns a robohash.org link) and Ferrum raises
# PendingConnectionsError when those hang, turning unrelated third-party availability into
# red specs.
module SystemSpecNetwork
  module_function

  # @param url [String] request URL as reported by Ferrum
  # @param server [Capybara::Server, nil] the app under test
  # @return [Boolean] true if the request may proceed
  def allowed?(url, server)
    return false if server.nil?

    uri = parse(url)
    return false if uri.nil?
    # data:, about: and blob: carry no host and reach no network.
    return true if uri.host.nil?

    # Compare parsed origin, never a URL prefix. In `http://127.0.0.1:80@evil.example/`,
    # `127.0.0.1:80` is userinfo and the real host is evil.example, so a prefix check on
    # "http://127.0.0.1:" would admit an off-origin request.
    uri.scheme == 'http' && uri.host == server.host && uri.port == server.port
  end

  def parse(url)
    URI.parse(url)
  rescue URI::InvalidURIError
    nil
  end
end
