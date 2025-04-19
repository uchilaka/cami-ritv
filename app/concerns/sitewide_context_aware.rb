# frozen_string_literal: true

module SitewideContextAware
  extend ActiveSupport::Concern

  def self.included(base)
    # Read more about what base.extend(ClassMethods) does https://stackoverflow.com/a/45110474
    base.extend ClassMethods
  end

  module ClassMethods
    include FooterHelper
    include ActionView::Helpers::AssetUrlHelper

    delegate :t, to: I18n

    def logo_url
      image_url('footer-logo.png')
    end
  end
end
