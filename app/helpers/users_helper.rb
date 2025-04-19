# frozen_string_literal: true

module UsersHelper
  def avatar_url(_user)
    # TODO: Create a metadata (aliased as profile) field in the user model
    #   and store the image_url there
    return profile_image_url if user_signed_in? && profile_image_url.present?

    image_url 'person-default.svg'
  end

  def profile_image_url
    @profile_image_url ||= current_user.profile['image_url']
  end
end
