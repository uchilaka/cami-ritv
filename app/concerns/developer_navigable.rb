# frozen_string_literal: true

module DeveloperNavigable
  extend ActiveSupport::Concern

  included do
    include SharedNavigable

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
  end
end
