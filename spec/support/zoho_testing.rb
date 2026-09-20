# frozen_string_literal: true

# Replays Zoho serverinfo from its recorded cassette instead of the live API.
#
# Zoho::API.serverinfo is a prerequisite for nearly every Zoho code path, so the Zoho specs
# load it in a `before` hook. Performed live, that is a
# GET https://accounts.zoho.com/oauth/serverinfo on *every* example in those files, which
# makes the suite non-hermetic: it fails whenever Zoho rate-limits the account, and it
# silently depends on network access in CI.
def load_zoho_serverinfo(region_alpha2: 'US')
  cassette_name = 'zoho/serverinfo'
  load_fixture = -> { Fixtures::Zoho::Serverinfo.new.invoke(:load, [], region_alpha2:) }

  # Some describe blocks already open this cassette in an `around` hook (see
  # `.serverinfo` in spec/lib/zoho/api/account_spec.rb). VCR raises on nesting two
  # cassettes of the same name, so replay through the open one rather than opening a second.
  return load_fixture.call if VCR.cassettes.any? { |cassette| cassette.name == cassette_name }

  options = vcr_cassettes[:zoho][:options].deep_merge(
    match_requests_on: %i[method uri],
    record: :none
  )

  VCR.use_cassette(cassette_name, options, &load_fixture)
end
