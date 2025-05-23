# frozen_string_literal: true

module AdministratorNavigable
  extend ActiveSupport::Concern

  included do
    include SharedNavigable

    def show_admin_menu?
      (user_signed_in? && current_user.has_role?(:admin)) || Rails.env.development?
    end

    def admin_menu
      @admin_menu ||= [
        { label: 'Products', path: '/products', admin: true },
        # TODO: Decide on whether services will be needed to bundle products
        #   together - or if this is redundant with invoices and the invoice
        #   template feature of PayPal (the flagship payment gateway). An argument
        #   could be made that services are needed to bundle products together
        #   for a subscription-based model, but this is not the primary use case.
        #   Another argument could be made that services are needed to bundle products
        #   as an abstraction layer for what PayPal's invoice templates already do.
        { label: 'Services', path: '/services', admin: true },
        { label: 'Features', path: '/admin/flipper', new_tab: true, admin: true, enabled: true },
        { label: 'Async Jobs', path: '/admin/jobs', new_tab: true, admin: true, enabled: true },
        # TODO: Update the destination of this managed link to CAMI 2.0 project once all
        #   the v1.0 stuff has been cut over to the 2.0 project (same-ish stuff, but now
        #   with InertiaJs driving the primary design for how data gets delivered to
        #   frontend components/SPAs
        {
          label: 'Work in progress',
          url: 'https://bit.ly/larcity-cami-wip',
          new_tab: true,
          admin: true,
          enabled: true,
        },
        { label: 'System Logs', url: system_log_url, admin: true, enabled: true },
        {
          label: 'Managed Links',
          url: 'https://app.bitly.com/BicibKENyrf/links',
          new_tab: true, admin: true, enabled: true,
        },
        {
          label: 'Storybook',
          url: storybook_url,
          new_tab: true, admin: true,
        },
        # TODO: Update AppUtils to compose the application's URL based on whether
        #   the NGINX tunnel is running or not.
        {
          label: 'Test email inbox',
          url: test_inbox_url,
          admin: true,
        },
        {
          label: 'Analytics',
          url: 'https://analytics.google.com/analytics/web/#/a47459054p256599245/admin',
          admin: true,
          enabled: true,
        },
        {
          label: 'PayPal Dashboard',
          url: paypal_developer_dashboard_url,
          admin: true,
          enabled: true,
        },
        {
          label: 'CRM Dashboard',
          url: "https://crm.zoho.com/crm/org#{crm_org_id}/tab/Home/begin",
          admin: true,
          enabled: true,
        },
        {
          label: 'Proxy Endpoints',
          url: 'https://dashboard.ngrok.com/endpoints?sortBy=updatedAt&orderBy=desc',
          admin: true,
          enabled: true,
        },
      ].map { |item| build_menu_item(item) }.filter(&:enabled)
    end
  end
end
