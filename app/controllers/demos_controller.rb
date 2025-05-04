# frozen_string_literal: true

class DemosController < ApplicationController
  include Demonstrable

  inertia_share navigation: demo_navigation_items

  skip_before_action :verify_authenticity_token

  layout 'inertiajs'

  def hero_simply_centered
    render inertia: 'demos/HeroSimplyCentered'
  end

  def feature_with_product_screenshot
    render inertia: 'demos/Feature/FeatureWithProductScreenshot', props: {
      title: 'Feature Sections',
      subtitle: 'With Product Screenshot',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      features: [
        {
          name: 'Push to deploy.',
          description:
            'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Maiores impedit perferendis suscipit eaque, iste dolor cupiditate blanditiis ratione.',
          iconKey: 'cloud-arrow-up-icon',
        },
        {
          name: 'SSL certificates.',
          description: 'Anim aute id magna aliqua ad ad non deserunt sunt. Qui irure qui lorem cupidatat commodo.',
          iconKey: 'lock-closed-icon',
        },
        {
          name: 'Database backups.',
          description: 'Ac tincidunt sapien vehicula erat auctor pellentesque rhoncus. Et magna sit morbi lobortis.',
          iconKey: 'server-icon',
        },
      ],
    }
  end

  def feature_with_2x2_grid
    render inertia: 'demos/Feature/FeatureWith2x2Grid', props: {
      title: 'Feature Sections',
      subtitle: 'With 2x2 Grid',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      features: [
        {
          name: 'Push to deploy.',
          description:
            'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Maiores impedit perferendis suscipit eaque, iste dolor cupiditate blanditiis ratione.',
          iconKey: 'cloud-arrow-up-icon',
        },
        {
          name: 'SSL certificates.',
          description: 'Anim aute id magna aliqua ad ad non deserunt sunt. Qui irure qui lorem cupidatat commodo.',
          iconKey: 'lock-closed-icon',
        },
        {
          name: 'Simple queues.',
          description:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
          iconKey: 'arrow-path-icon',
        },
        {
          name: 'Advanced security',
          description:
            'Arcu egestas dolor vel iaculis in ipsum mauris. Tincidunt mattis aliquet hac quis. Id hac maecenas ac donec pharetra eget.',
          iconKey: 'fingerprint-icon',
        },
      ],
    }
  end

  def pricing_with_emphasized_tier
    render inertia: 'demos/PricingWithEmphasizedTier', props: {
      title: 'Pricing',
      subtitle: 'Choose the right plan for you',
      description: 'Choose an affordable plan that’s packed with the best features for engaging your audience, creating customer loyalty, and driving sales.',
      tiers: [
        {
          name: 'Hobby',
          id: 'tier-hobby',
          href: '#',
          priceMonthly: '$29',
          description: "The perfect plan if you're just getting started with our product.",
          features: ['25 products', 'Up to 10,000 subscribers', 'Advanced analytics', '24-hour support response time'],
          featured: false,
        },
        {
          name: 'Enterprise',
          id: 'tier-enterprise',
          href: '#',
          priceMonthly: '$99',
          description: 'Dedicated support and infrastructure for your company.',
          features: [
            'Unlimited products',
            'Unlimited subscribers',
            'Advanced analytics',
            'Dedicated support representative',
            'Marketing automations',
            'Custom integrations',
          ],
          featured: true,
        }
      ],
    }
  end

  def simple_sign_in
    render inertia: 'demos/SimpleSignIn', props: {
      title: 'Simple Sign In',
      subtitle: 'Sign in to your account',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      # formAction: user_google_omniauth_authorize_path,
      # formMethod: :get,
      # formId: 'simple-sign-in-form',
      # buttonLabel: t('devise.omniauth.ctas.sign_in_with_provider', provider: 'Google'),
    }
  end

  def work_with_us
    render inertia: 'demos/WorkWithUs', props: {
      title: 'Work With Us',
      subtitle: 'Join our team and make a difference',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      # formAction: user_google_omniauth_authorize_path,
      # formMethod: :get,
      # formId: 'work-with-us-form',
      # buttonLabel: t('devise.omniauth.ctas.sign_in_with_provider', provider: 'Google'),
    }
  end

  def newsletter
    render inertia: 'demos/Newsletter', props: {
      title: 'Newsletter',
      subtitle: 'Stay updated with our latest news',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      # formAction: user_google_omniauth_authorize_path,
      # formMethod: :get,
      # formId: 'newsletter-form',
      # buttonLabel: t('devise.omniauth.ctas.sign_in_with_provider', provider: 'Google'),
    }
  end

  def testimonials
    render inertia: 'demos/Testimonials', props: {
      title: 'Testimonials',
      subtitle: 'What our customers say about us',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      # formAction: user_google_omniauth_authorize_path,
      # formMethod: :get,
      # formId: 'testimonials-form',
      # buttonLabel: t('devise.omniauth.ctas.sign_in_with_provider', provider: 'Google'),
    }
  end

  def blog_highlights
    render inertia: 'demos/BlogHighlights', props: {
      title: 'Blog Highlights',
      subtitle: 'Latest articles from our blog',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
      # formAction: user_google_omniauth_authorize_path,
      # formMethod: :get,
      # formId: 'blog-highlights-form',
      # buttonLabel: t('devise.omniauth.ctas.sign_in_with_provider', provider: 'Google'),
    }
  end

  def content_sections
    render inertia: 'demos/ContentSections', props: {
      title: 'Content Sections',
      subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.',
    }
  end
end
