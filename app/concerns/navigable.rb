# frozen_string_literal: true

module Navigable
  extend ActiveSupport::Concern

  included do
    include AdministratorNavigable
    include DeveloperNavigable

    def main_menu
      @main_menu ||=
        if @main_menu.nil?
          demo_sub_menu = showcase_nav_item[:submenu].map do |menu_item|
            label, path = menu_item.values_at(:name, :href)
            { label:, path: }
          end
          # TODO: Internationalize these link labels
          # TODO: Include accessibility information for screen readers
          #  and other assistive technologies
          # TODO: Include icon classes for each link
          # TODO: Use pundit policy to determine which links to display
          # TODO: Memoize and return as @main_menu after policy checks
          # TODO: Cache this menu response for 1 hour
          [
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
            {
              label: t('shared.navbar.demos'),
              path: '#',
              submenu: demo_sub_menu,
            },
            {
              label: t('shared.navbar.accounts'),
              path: accounts_path,
            },
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
              path: '/about-us',
              feature: true,
            },
          ].map { |item| build_menu_item(item) }.filter(&:enabled)
        end
    end

    def profile_menu
      @profile_menu ||= [
        { label: t('shared.navbar.registration'), path: edit_user_registration_path },
      ].map { |item| build_menu_item(item) }
    end

    def public_menu
      @public_menu ||= (main_menu.filter(&:public) + main_menu.filter(&:feature))
    end
  end
end
