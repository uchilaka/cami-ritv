# frozen_string_literal: true

require 'rails_helper'

# Guards spec/support/system_spec_network.rb, which is the only thing keeping browser-driven
# specs off the public internet. Tested directly rather than through a browser: a fetch to a
# non-resolving host fails on DNS whether or not interception works, so a browser-level test
# would pass for the wrong reason.
RSpec.describe SystemSpecNetwork do
  let(:server) { instance_double(Capybara::Server, host: '127.0.0.1', port: 4000) }

  describe '.allowed?' do
    it 'allows the app under test' do
      expect(described_class.allowed?('http://127.0.0.1:4000/invoices', server)).to be(true)
    end

    it 'allows inline resources that reach no network' do
      %w[data:image/png;base64,iVBORw0KGgo about:blank blob:http://127.0.0.1:4000/abc].each do |url|
        expect(described_class.allowed?(url, server)).to be(true), "expected #{url} to be allowed"
      end
    end

    it 'blocks an external host' do
      expect(described_class.allowed?('https://robohash.org/example.png', server)).to be(false)
    end

    it 'blocks a different port on the same host' do
      expect(described_class.allowed?('http://127.0.0.1:9999/x', server)).to be(false)
    end

    it 'blocks a URL whose userinfo mimics the app origin' do
      # `127.0.0.1:4000` is userinfo here; the real host is evil.example. A prefix check on
      # "http://127.0.0.1:" would have admitted this.
      url = 'http://127.0.0.1:4000@evil.example/avatar.png'
      expect(described_class.allowed?(url, server)).to be(false)
    end

    it 'blocks when the server is not running' do
      expect(described_class.allowed?('http://127.0.0.1:4000/x', nil)).to be(false)
    end

    it 'blocks an unparseable URL' do
      expect(described_class.allowed?('http://[bad', server)).to be(false)
    end
  end
end
