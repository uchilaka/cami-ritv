# frozen_string_literal: true

module AdministratorNavigable
  extend ActiveSupport::Concern

  included do
    include SharedNavigable

    def show_admin_menu?
      (user_signed_in? && current_user.has_role?(:admin)) || Rails.env.development?
    end

    def native_objects_crm_base_url
      @native_objects_crm_base_url ||=
        begin
          public_url = ENV['PUBLIC_DOMAIN_URL']
          if AppUtils.resource_is_okayish?(public_url)
            public_url
          else
            ENV['SERVER_URL']
          end
        end
    end

    def show_native_objects_admin_link?
      base_url = ENV['PUBLIC_DOMAIN_URL']
      unless Rails.env.development?
        return false if base_url.blank?
      end

      base_url ||= ENV['SERVER_URL']
      return false if base_url.blank?

      true
    end

    def admin_menu
      @admin_menu ||= [
        { label: I18n.t("globals.shared.navbar.products"), path: '/products', admin: true },
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
          label: I18n.t("globals.labels.navbar.wip"),
          url: 'https://bit.ly/larcity-cami-wip',
          new_tab: true,
          admin: true,
          enabled: true,
        },
        { label: I18n.t("globals.labels.navbar.sys_logs"), url: system_log_url, admin: true, enabled: true },
        {
          label: I18n.t("globals.labels.navbar.managed_links"),
          url: 'https://app.bitly.com/BicibKENyrf/links',
          new_tab: true, admin: true, enabled: true,
        },
        {
          label: I18n.t("globals.labels.navbar.vault"),
          url: 'https://bitwarden.com/download/',
          new_tab: true, admin: true,
        },
        {
          label: I18n.t("globals.labels.navbar.storybook"),
          url: storybook_url,
          new_tab: true, admin: true,
        },
        # TODO: Update AppUtils to compose the application's URL based on whether
        #   the NGINX tunnel is running or not.
        {
          label: I18n.t("globals.labels.navbar.test_inbox"),
          url: test_inbox_url,
          admin: true,
          enabled: true,
        },
        {
          label: I18n.t("globals.labels.navbar.analytics_dashboard"),
          url: 'https://analytics.google.com/analytics/web/#/p256599245/reports/intelligenthome',
          admin: true,
          enabled: true,
        },
        {
          label: I18n.t("globals.labels.navbar.analytics_admin"),
          url: 'https://analytics.google.com/analytics/web/#/a47459054p256599245/admin',
          admin: true,
          enabled: true,
        },
        {
          label: I18n.t("globals.labels.navbar.paypal_dashboard"),
          url: paypal_developer_dashboard_url,
          admin: true,
          enabled: true,
        },
        show_native_objects_admin_link? && {
          label: 'Native Objects CRM Dashboard',
          url: native_objects_crm_base_url,
          admin: true,
        },
        {
          label: 'CRM Dashboard',
          url: zoho_crm_dashboard_url,
          admin: true,
          enabled: true,
        },
        {
          label: 'Proxy Endpoints',
          url: 'https://dashboard.ngrok.com/endpoints?sortBy=updatedAt&orderBy=desc',
          admin: true,
          enabled: true,
        },
        notion_webhook.present? && {
          label: 'Notion Integration Dashboard',
          url: notion_webhook.dashboard_url,
          admin: true,
        },
      ].select(&:itself).map { |item| build_menu_item(item) }.filter(&:enabled)
    end

    private

    def notion_webhook
      @notion_webhook ||= Webhook.friendly.find('notion', allow_nil: true)
    end
  end
end
