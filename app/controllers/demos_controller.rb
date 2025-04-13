class DemosController < ApplicationController
  def hero_simply_centered
    render inertia: 'demos/HeroSimplyCentered', props: {
      navigation: [
        { name: 'Product', href: '#' },
        { name: 'Features', href: '#' },
        { name: 'Marketplace', href: '#' },
        { name: 'Company', href: '#' },
      ]
    }
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
      ]
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
      ]
    }
  end
end
