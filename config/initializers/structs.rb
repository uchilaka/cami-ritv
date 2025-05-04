# frozen_string_literal: true

# TODO: Implement Danger CI linting to call out when this file is changed and
#   require an additional review as well as updates to the deployment plan for
#   the needed outage to deploy the changes (requires a full restart of the
#   application server to reload the initializers)
# Initialize a struct for the Business model
Struct.new('Company', :name, :email, :tax_id, keyword_init: true)
# Initialize a struct for vendor API credentials & config combos
#   saved in the app credentials file
Struct.new('VendorConfig', :base_url, :api_base_url, :client_id, :client_secret, keyword_init: true)
# Initialize a struct of navbar menu items
# TODO: Implement as MenuItem (in "navbar" context) active record class
#   with support for I18n, accessibility features, icons, pundit and
#   rolify policy checks, Redis caching (with a 1-hour and menu record
#   change cache expiration)
Struct.new(
  'NavbarItem',
  :id,
  :label,
  :url,
  :path,
  :new_tab,
  :new_window,
  :section,
  :submenu,
  :feature,
  :feature_flag,
  :enabled,
  :public,
  :admin,
  keyword_init: true
)
