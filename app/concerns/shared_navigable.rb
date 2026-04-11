# frozen_string_literal: true

module SharedNavigable
  extend ActiveSupport::Concern

  included do
    include DynamicDomElementCapable
    include Rails.application.routes.url_helpers

    private

    # @deprecated Refactor this method to fetch a configured resource link from the application credentials store instead
    def storybook_url
      'http://localhost:6006'
    end

    # @deprecated Refactor this method to fetch a configured resource link from the application credentials store instead
    def test_inbox_url
      # Mailhog URL
      'http://localhost:8025'
    end

    # @deprecated Refactor this method to fetch a configured resource link from the application credentials store instead
    def paypal_developer_dashboard_url
      paypal_env = Rails.env.production? ? 'live' : 'sandbox'

      "https://developer.paypal.com/dashboard/applications/#{paypal_env}"
    end

    def zoho_crm_dashboard_url
      "https://crm.zoho.com/crm/org#{crm_org_id}/tab/Home/begin"
    end

    def system_log_url
      @system_log_url ||= VirtualOfficeManager.logstream_vendor_url
    end

    def build_menu_item(item)
      label_or_name = item[:label] || item[:name]
      item[:id] ||= anonymous_dom_id(label_or_name)
      item[:enabled] ||= calculate_enabled(item)
      item[:admin] ||= false
      item[:public] ||= false
      item[:order] ||= 99
      # Return a new Struct::NavbarItem instance
      Struct::NavbarItem.new(item)
    end

    def calculate_enabled(item)
      return true if item[:public]

      # Optionally compose feature flag for menu item
      item[:feature_flag] ||= :"feat__#{item[:label].to_s.parameterize(separator: '_')}"
      return Flipper.enabled?(item[:feature_flag]) if current_user.blank?

      # Check if feature flag is enabled for current user
      Flipper.enabled?(item[:feature_flag], current_user)
    end
  end
end
