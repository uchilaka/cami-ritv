# frozen_string_literal: true

module Devise
  module Omniauth
    module LinksHelper
      def omniauth_cta_label(provider)
        if current_path == new_registration_path(resource)
          t('devise.omniauth.ctas.sign_up_with_provider', provider: provider_name(provider))
        else
          t('devise.omniauth.ctas.sign_in_with_provider', provider: provider_name(provider))
        end
      end

      def provider_name(provider)
        ::OmniAuth::Utils.camelize(provider)
      end
    end
  end
end
