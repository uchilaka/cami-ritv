# frozen_string_literal: true

require 'commands/lar_city/cli/base_cmd'

class FeaturesCmd < LarCity::CLI::BaseCmd
  namespace 'features'

  desc 'init', 'Initialize app features, reverse merging default states'
  def init
    current_features = Flipper.features.map(&:key).map(&:to_sym)
    app.config_for(:features).each do |feature, options|
      next if current_features.include?(feature)

      Flipper.add(feature)
      if options[:enabled]
        Flipper.enable(feature)
      else
        Flipper.disable(feature)
      end
    end
  end
end
