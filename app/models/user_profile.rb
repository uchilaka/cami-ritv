# frozen_string_literal: true

# JSONB modeling guide:
# https://betacraft.com/2023-06-08-active-model-jsonb-column/#:~:text=Bringing%20it%20all%20together
class UserProfile
  include ActiveModel::API
  include ActiveModel::Serialization
  extend ActiveModel::Callbacks
  include ActiveModel::Dirty

  attr_accessor :image_url,
                :phone_e164,
                :phone_country

  define_attribute_methods :image_url, :phone_e164, :phone_country

  def attributes
    {
      'image_url' => nil,
      'phone_e164' => nil,
      'phone_country' => nil,
    }
  end
end
