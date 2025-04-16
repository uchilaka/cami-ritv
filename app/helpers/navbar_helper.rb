# frozen_string_literal: true

module NavbarHelper
  include UsersHelper

  def navbar_version
    '2.0'
  end

  def current_path
    request.fullpath
  end

  def navbar_link_classes(is_current_page: false)
    if is_current_page
      return 'block py-2 px-3 text-white bg-blue-700 rounded md:bg-transparent md:text-blue-700 md:p-0 ' \
             'md:dark:text-blue-500'
    end

    'block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 ' \
      'dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white ' \
      'md:dark:hover:bg-transparent dark:border-gray-700'
  end

  def profile_link_classes
    'block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 ' \
      'dark:text-gray-200 dark:hover:text-white'
  end

  def profile_name
    @profile_name ||= current_user.nickname || current_user.given_name || current_user.email
  end

  def profile_email
    @profile_email ||= current_user.email
  end

  def profile_photo_url
    avatar_url(current_user)
  end

  def show_admin_menu?
    (user_signed_in? && current_user.has_role?(:admin)) || Rails.env.development?
  end

  def main_menu
    # TODO: Internationalize these link labels
    # TODO: Include accessibility information for screen readers
    #  and other assistive technologies
    # TODO: Include icon classes for each link
    # TODO: Use pundit policy to determine which links to display
    # TODO: Memoize and return as @main_menu after policy checks
    # TODO: Cache this menu in Redis for 1 hour
    @main_menu ||= [
      {
        label: t('shared.navbar.home'),
        path: root_path,
        public: true,
      },
      {
        label: t('shared.navbar.dashboard'),
        path: '/app/dashboard',
      },
      {
        label: t('shared.navbar.invoices'),
        path: '/app/invoices',
      },
      # {
      #   label: t('shared.navbar.accounts'),
      #   path: accounts_path,
      # },
      # {
      #   label: t('shared.navbar.services'),
      #   path: services_path
      # },
      # TODO: Eventually take products off this list - intended navigation
      #   is to traverse via services to the component products
      # {
      #   label: t('shared.navbar.products'),
      #   path: products_path
      # },
      {
        label: t('shared.navbar.about'),
        path: '/app/about',
        public: true,
      },
    ].map { |item| build_menu_item(item) }.filter(&:enabled)
  end

  def profile_menu
    @profile_menu ||= [
      { label: t('shared.navbar.registration'), path: edit_user_registration_path },
    ].map { |item| build_menu_item(item) }
  end

  def public_menu
    @public_menu ||= main_menu.filter(&:public)
  end

  def developer_menu
    @developer_menu ||= [
      {
        label: 'Flowbite :: Integration Guide',
        url: 'https://flowbite.com/docs/getting-started/rails/',
        section: 'UI Library',
        public: true,
      },
      { label: 'Flowbite :: Blocks', url: 'https://flowbite.com/blocks/', section: 'UI Library', public: true },
      { label: 'Flowbite :: Icons', url: 'https://flowbite.com/icons/', section: 'UI Library', public: true },
    ].map { |item| build_menu_item(item) }
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
      { label: 'Sidekiq', path: '/admin/sidekiq', new_tab: true, admin: true, enabled: true },
      { label: 'System Logs', url: system_log_url, admin: true, enabled: true },
      {
        label: 'Storybook',
        url: storybook_url,
        new_tab: true, admin: true,
        enabled: Rails.env.development?,
      },
      # TODO: Update AppUtils to compose the application's URL based on whether
      #   the NGINX tunnel is running or not.
      {
        label: 'Test email inbox',
        url: test_inbox_url,
        admin: true,
        enabled: Rails.env.development?,
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

  def system_log_url
    @system_log_url ||= VirtualOfficeManager.logstream_vendor_url
  end

  def build_menu_item(item)
    item[:enabled] ||= calculate_enabled(item)
    item[:admin] ||= false
    item[:public] ||= false
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
