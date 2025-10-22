# frozen_string_literal: true

require 'concerns/operating_system_detectable'
require_relative 'utils/class_helpers'

module LarCity
  module CLI
    module EnvHelpers
      extend Utils::ClassHelpers

      def self.define_class_options(thor_class)
        thor_class.class_option :environment,
                                type: :string,
                                aliases: '--env',
                                desc: 'Environment',
                                required: false
      end

      def self.included(base)
        base.include OperatingSystemDetectable

        # Throw an error unless included in a Thor class
        missing_ancestor_msg = <<~MSG
          #{base.name} is not a descendant of Thor or Thor::Group.
          #{name} can only be included in Thor or Thor::Group descendants.
        MSG
        raise missing_ancestor_msg unless has_thor_ancestor?(base)

        missing_options_method_msg = <<~MSG
          #{base.name} does not support options.
          #{name} can only be included in Thor classes that support options.
        MSG
        raise missing_options_method_msg unless supports_options?(base)

        base.include InstanceMethods
      end

      module InstanceMethods
        protected

        def detected_environment
          options[:environment] || Rails.env
        end
      end
    end
  end
end
