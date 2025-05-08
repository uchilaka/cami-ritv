# frozen_string_literal: true

module FooterHelper
  def footer_resource_links
    [
      [
        t('shared.footer.fontawesome_icons'),
        'https://fontawesome.com/search',
      ],
      [
        t('shared.footer.flowbite_icons'),
        'https://flowbite.com/icons/',
      ],
      [
        t('shared.footer.flowbite_integration_guide'),
        'https://flowbite.com/docs/getting-started/rails/',
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
      [
        t('shared.footer.tailwind_theming'),
        'https://v3.tailwindcss.com/docs/theme',
      ],
      [
        t('shared.footer.wai_aria_guide'),
        'https://w3c.github.io/aria',
      ],
      [
        t('shared.footer.paypal_sandbox_guide'),
        'https://developer.paypal.com/tools/sandbox/',
      ],
      [
        t('shared.footer.ruby_doc'),
        'https://www.ruby-lang.org/en/documentation/',
      ],
      [
        t('shared.footer.zoho_crm_api_guide'),
        'https://www.zoho.com/crm/developer/docs/api/v7/?crmprod=1',
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
