# frozen_string_literal: true

module Demonstrable
  extend ActiveSupport::Concern

  def self.included(base)
    # Make these methods available on instances of the class as well
    include ClassMethods

    # Read more about what base.extend(ClassMethods) does https://stackoverflow.com/a/45110474
    base.extend ClassMethods
  end

  module ClassMethods
    def demo_navigation_items
      [
        { name: 'Product', href: '#' },
        showcase_nav_item,
        { name: 'Marketplace', href: '#' },
        { name: 'Company', href: '#' },
      ]
    end

    def showcase_nav_item
      {
        name: I18n.t('shared.navbar.demos'),
        href: '#',
        submenu: [
          { name: 'InertiaJS Dashboard', href: '/demos/hello-inertia-rails' },
          { name: 'Hero Simply Centered', href: '/demos/hero/simply-centered' },
          { name: 'Feature with Product Screenshot ', href: '/demos/feature/with-product-screenshot' },
          { name: 'Feature with 2x2 Grid', href: '/demos/feature/with-2x2-grid' },
          { name: 'Pricing with Emphasized Tier', href: '/demos/pricing/with-emphasized-tier' },
          { name: 'Simple Sign In', href: '/demos/simple-sign-in' },
          { name: 'Work with us', href: '/demos/work-with-us' },
          { name: 'Newsletter', href: '/demos/newsletter' },
          { name: 'Testimonials', href: '/demos/testimonials' },
        ].sort_by { |h| h[:name] },
      }
    end
  end
end
