# frozen_string_literal: true

module API
  module V1
    class FeaturesController < ApplicationController
      def index
        render json: { features:, flags: features.keys }
      end

      def features
        @features ||=
          begin
            feature_set = {}
            Flipper.features.each do |feature|
              feature_set[feature.key.to_sym] = Flipper.enabled?(feature.key, current_user)
            end
            feature_set
          end
      end
    end
  end
end
