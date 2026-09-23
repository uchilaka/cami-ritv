# frozen_string_literal: true

require 'English' # for $CHILD_STATUS

module LarCity
  module CLI
    # Provisioning for the docker networks compose expects to already exist.
    #
    # Shared by InitApp and ServicesCmd rather than duplicated: every entrypoint that
    # brings containers up needs the same guarantee, and a second copy of this list is
    # exactly how `.docker/bin/start-essential` ended up able to fail on a clean machine
    # while `.docker/bin/start` worked.
    module ServiceNetworks
      # The first two are declared `external: true` in compose.yml, so Compose will not
      # create them. `larcity-apps-net` is a forward-looking cross-environment target
      # that no compose file references yet. Order matters only for output.
      SERVICE_NETWORKS = %w[larcity_apps larcity-beta-net larcity-apps-net].freeze

      protected

      # `larcity_apps` is this project's network. platform-monorepo declares it external
      # in every package and points at "`.docker/bin/start` in the cami-ritv project" to
      # bring it up, so creating it here is the contract that project already documents.
      #
      # `larcity-beta-net` belongs to platform-monorepo's Traefik spoke, which creates it
      # with these same settings. We create it only when it is absent, so this project
      # can still boot standalone with the platform down.
      #
      # `larcity-apps-net` is a cross-environment network we intend to migrate onto.
      # Nothing references it yet, so creating it is inert today -- it exists so the
      # platform side can adopt it without a chicken-and-egg wait on this project.
      def ensure_service_networks!
        SERVICE_NETWORKS.each do |network_name|
          next if service_network_exists?(network_name)

          say_info "Setting up '#{network_name}' network..."
          # NOTE: --ipv6 is a boolean flag. `--ipv6 false` is parsed as a second
          # positional argument and docker rejects the whole command with
          # "requires 1 argument".
          run 'docker network create', network_name, '--driver bridge', '--ipv6=false'
        end
      end

      def service_network_exists?(network_name)
        list_of_networks.include?(network_name)
      end

      # NOTE: an empty result here is indistinguishable from "docker is not running",
      # and callers use it to decide whether to CREATE a network -- so check the exit
      # status rather than letting a dead daemon look like an empty network list.
      def list_of_networks
        return [] if pretend?

        output = `docker network ls --format '{{.Name}}'`
        raise 'Unable to list docker networks. Is the Docker daemon running?' unless $CHILD_STATUS.success?

        output.split("\n")
      end
    end
  end
end
