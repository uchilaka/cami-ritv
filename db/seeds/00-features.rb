# frozen_string_literal: true

load "#{Rails.root}/lib/commands/features_cmd.thor"

FeaturesCmd.new.invoke(:init, [])
