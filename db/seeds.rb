# frozen_string_literal: true

require 'lib/commands/features_cmd'
require 'lib/commands/lar_city/cli/devkit_cmd'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Load all thor fixture tasks
Dir[Rails.root.join('lib', 'tasks', 'fixtures', '*.thor')].each { |file| load file }

# Load all seed files in db/seeds
Dir[Rails.root.join('db', 'seeds', '**', '*.rb')].each { |seed| load seed }

# Initialize feature flags from config/features.yml
FeaturesCmd.new.invoke(:init, [], verbose: true)

# Setup webhooks for Notion integration
LarCity::CLI::DevkitCmd
  .new.invoke(:setup_webhooks, [], vendor: 'notion', verbose: true)
