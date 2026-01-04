# frozen_string_literal: true

# Abstract module to be included in workflows that handle webhooks
# for different vendors and datasets.
module WebhookingWorkflow
  def self.included(base)
    base.extend ClassMethods

    base.include Interactor unless base.ancestors.include?(Interactor)

    base.delegate :dataset, :webhook, :message, to: :context
    base.delegate :actions_map, to: :class

    base.include InstanceMethods
  end

  # Abstract class methods to be implemented by including classes.
  module ClassMethods
    def actions_map
      return @actions_map if defined?(@actions_map)

      raise NotImplementedError, "#{name} must implement .actions_map"
    end

    # Support configurable actions_map with optional default values
    def set_actions_map(hash = {}, default: {}, &)
      @actions_map =
        begin
          # Use to be Hash.new
          register = ActiveSupport::OrderedOptions.new(default)
          composed_hash =
            if block_given?
              yield hash
            else
              hash
            end
          register.merge(composed_hash)
        end
    end

    def supported?(vendor_slug:)
      raise NotImplementedError, "#{name} must implement .supported?(vendor_slug:)"
    end

    def vendor_supported?(slug)
      raise NotImplementedError, "#{name} must implement .vendor_supported?(slug)"
    end

    def dataset_supported?(dataset)
      raise NotImplementedError, "#{name} must implement .dataset_supported?(dataset)"
    end
  end

  # Abstract/generic instance methods to be implemented/overwritten
  # by including classes.
  module InstanceMethods
    def new_record?
      @new_record ||= webhook&.new_record?
    end

    def force?
      context.force || false
    end

    def slug
      [vendor.to_s, pluralized_dataset_or_blank].compact.join('-').to_sym
    end

    def vendor
      return @vendor if defined?(@vendor)

      raise NotImplementedError, "#{self.class.name} must implement #vendor"
    end

    protected

    def pluralized_dataset_or_blank
      return nil unless dataset.present?

      dataset.to_s.pluralize
    end
  end
end
