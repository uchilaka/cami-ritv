# frozen_string_literal: true

# For specs that stub HTTP themselves -- Faraday's test adapter, or a stub on Faraday.get --
# rather than through a VCR cassette.
#
# `hook_into :faraday` inserts VCR middleware into EVERY Faraday connection, including ones
# built with Faraday's test adapter. With `allow_http_connections_when_no_cassette = false`
# VCR therefore raises UnhandledHTTPRequestError before the spec's own stubs ever run.
# Turning VCR off for these examples lets those stubs handle the request, while leaving
# unrecorded HTTP blocked everywhere else.
#
# Apply with `stubs_http: true` metadata on the example group (see rails_helper.rb).
RSpec.shared_context 'with self-stubbed http', shared_context: :metadata do
  around do |example|
    VCR.turned_off(ignore_cassettes: true) { example.run }
  end
end
