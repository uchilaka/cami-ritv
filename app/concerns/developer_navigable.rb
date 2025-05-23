# frozen_string_literal: true

module DeveloperNavigable
  extend ActiveSupport::Concern

  included do
    include SharedNavigable

    def developer_menu
      @developer_menu ||= [
        {
          label: t('shared.footer.wai_aria_guide'),
          url: 'https://w3c.github.io/aria',
          public: true,
        },
        {
          label: t('shared.footer.open_source_guides'),
          url: 'https://opensource.guide/',
          section: 'Guides',
          public: true,
        },
        {
          label: t('shared.footer.flowbite_integration_guide'),
          url: 'https://flowbite.com/docs/getting-started/rails/',
          section: 'UI Library',
          public: true,
        },
        {
          label: t('shared.footer.tailwind_theming'),
          url: 'https://v3.tailwindcss.com/docs/theme',
          section: 'Guides',
          public: true,
        },
        {
          label: t('shared.footer.rails_guides'),
          url: 'https://guides.rubyonrails.org/v8.0/index.html',
          section: 'Guides',
          public: true,
        },
      ].map { |item| build_menu_item(item) }
    end
  end
end
