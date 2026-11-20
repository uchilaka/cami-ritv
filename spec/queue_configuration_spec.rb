# frozen_string_literal: true

require 'rails_helper'

# Every Rails environment must have its own section in config/queue.yml.
#
# Solid Queue does not fail when an environment is missing: SolidQueue::Configuration
# falls back to its built-in worker defaults (queues "*", 3 threads) without a warning.
# With "*" the worker claims from a single relation ordered by job priority alone, so
# the queue order below stops mattering and RAILS_QUEUE_THREADS is ignored. Lab ran that
# way unnoticed until LAR-368. Iterating config/environments/ means the next environment
# added without a section fails here instead of starting cleanly on the wrong config.
RSpec.describe 'config/queue.yml' do
  environments = Rails.root.glob('config/environments/*.rb').map { |path| path.basename('.rb').to_s }.sort

  environments.each do |env|
    context "for the #{env} environment" do
      # config_for returns nil for an environment with no section -- the same gap Solid
      # Queue papers over with its defaults.
      subject(:config) { Rails.application.config_for(:queue, env:) }

      it 'declares its own workers' do
        expect(config&.dig(:workers)).to be_present
      end

      it 'drains the explicit queue list in priority order, not the "*" wildcard' do
        expect(config&.dig(:workers, 0, :queues)).to start_with('critical', 'high')
      end
    end
  end
end
