# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SitewideContextAware

  inertia_share footer_resource_links: footer_resource_links,
                footer_company_links: [
                  { label: t('accessibility.footer.about'), href: '#' },
                  {
                    label: t('accessibility.footer.contact'),
                    href: 'mailto:support@lar.city?subj=Email%20contact%20via%20website'
                  },
                ],
                logo: {
                  url: logo_url,
                  aria_label: t('accessibility.footer.logo'),
                }
end
