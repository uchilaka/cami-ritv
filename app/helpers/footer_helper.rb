# frozen_string_literal: true

module FooterHelper
  def footer_resource_links
    [
      [
        t('shared.footer.fontawesome_icons'),
        'https://fontawesome.com/search',
      ],
      [
        t('shared.footer.flowbite_blocks'),
        'https://flowbite.com/blocks/',
      ],
      [
        t('shared.footer.flowbite_icons'),
        'https://flowbite.com/icons/',
      ],
      [
        t('shared.footer.component_library'),
        'https://flowbite.com/docs/getting-started/introduction/',
      ],
      [
        t('shared.footer.tailwind_flex'),
        'https://v3.tailwindcss.com/docs/flex',
      ],
      [
        t('shared.footer.tailwind_blocks'),
        'https://tailwindcss.com/plus/ui-blocks',
      ],
      # [
      #   t('shared.footer.mongoid_docs'),
      #   'https://www.mongodb.com/docs/mongoid/8.1/',
      # ],
      [
        t('shared.footer.turbo_handbook'),
        'https://turbo.hotwired.dev/handbook/introduction',
      ],
    ]
  end
end
