# frozen_string_literal: true

require "#{Rails.root}/lib/commands/lar_city/cli/tunnel_cmd"

LarCity::CLI::TunnelCmd.new.invoke(:init, [], tailscale: true, verbose: Rails.env.development?)
