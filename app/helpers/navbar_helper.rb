# frozen_string_literal: true

module NavbarHelper
  include Demonstrable
  include UsersHelper
  include Navigable

  def navbar_version
    '2.0'
  end

  def current_path
    request.fullpath
  end

  def navbar_link_classes(is_current_page: false)
    return navbar_link_classes_for_current_page if is_current_page

    navbar_link_generic_classes
  end

  def navbar_link_generic_classes
    'block py-2 px-3 text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 ' \
      'dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white ' \
      'md:dark:hover:bg-transparent dark:border-gray-700'
  end

  def navbar_link_classes_for_current_page
    'block py-2 px-3 text-white bg-blue-700 rounded md:bg-transparent md:text-blue-700 md:p-0 ' \
      'md:dark:text-blue-500'
  end

  def profile_link_classes
    'block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 ' \
      'dark:text-gray-200 dark:hover:text-white'
  end

  def profile_name
    @profile_name ||= current_user.nickname || current_user.given_name || current_user.email
  end

  def profile_email
    @profile_email ||= current_user.email
  end

  def profile_photo_url
    avatar_url(current_user)
  end
end
