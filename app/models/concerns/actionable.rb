# frozen_string_literal: true

module Actionable
  extend ActiveSupport::Concern

  # require implementation of supported_actions method
  included do |base|
    extend ClassMethods
    include InstanceMethods

    raise StandardError, "#{base.name} must be descended from ActiveRecord::Base" \
      unless base.ancestors.include?(ActiveRecord::Base)

    raise NotImplementedError, "#{name}.supported_actions method MUST be implemented" \
      unless base.respond_to?(:supported_actions)
  end

  module ClassMethods
    def available_actions
      @available_actions ||= %i[show edit new create update destroy back]
    end

    def supported_actions(*actions)
      invalid_values = actions - available_actions
      raise ArgumentError, "#{name}.supported_actions must return an array with valid values" \
        unless invalid_values.none?

      self.define_method(:supported_actions) do
        actions.presence || []
      end
    end
  end

  module InstanceMethods
    include Rails.application.routes.url_helpers

    def default_url_options
      VirtualOfficeManager
        .default_url_options
        .merge(locale: I18n.locale)
    end

    def resources_url(args = {})
      url_method_name = :"#{self.class.name.to_s.pluralize.underscore}_url"
      args.merge!(protocol: :https) if AppUtils.use_secure_protocol?
      send(url_method_name, **args)
    end

    def resource_url(resource, args = {})
      url_method_name = :"#{resource.class.name.to_s.underscore}_url"
      args.merge!(protocol: :https) if AppUtils.use_secure_protocol?
      send(url_method_name, resource, **args)
    end

    # TODO: Evaluate Pundit policy in determining :showable? in Actionable module
    def readable?
      supported_actions.include?(:show)
    end

    def editable?
      supported_actions.include?(:edit)
    end

    # TODO: Evaluate Pundit policy in determining :destroyable? in Actionable module
    def destroyable?
      supported_actions.include?(:destroy)
    end

    def actions(resource = nil)
      resource ||= self if self.class.ancestors.include? ActiveRecord::Base
      resource_name = resource.class.name.to_s || 'resource'
      @actions = {
        back: {
          dom_id: SecureRandom.uuid,
          http_method: 'GET',
          label: "Back to #{resource_name.pluralize}",
          url: resources_url
        }
      }
      if destroyable?
        @actions[:delete] = {
          dom_id: SecureRandom.uuid,
          http_method: 'DELETE',
          label: 'Delete',
          url: resource_url(resource, format: :json)
        }
      end
      if readable?
        @actions[:show] = {
          dom_id: SecureRandom.uuid,
          http_method: 'GET',
          label: "#{resource_name} details",
          url: resource_url(resource)
        }
      end
      if editable?
        @actions[:edit] = {
          dom_id: SecureRandom.uuid,
          http_method: 'GET',
          label: 'Edit',
          url: resource_url(resource)
        }
      end
      @actions
    end

    def actions_as_list
      actions
        .entries
        .sort_by { |k, _h| k }
        .map do |key, action_hash|
          { key:, **action_hash }
        end
    end
  end
end
