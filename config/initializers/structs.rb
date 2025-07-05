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
  :order,
  keyword_init: true
)
# TODO: Implement a deal model for integrations with Zoho / a Notion deal database
#   - Calculate :days_since_last_contact based on the last_contacted_at field
#   - Add corresponding roles on the deal for upserted app contacts: :owner,
#     :decision_maker, :contact
#   - Add corresponding deal stages: :lead, :qualified, :proposal, :negotiation,
#     :won, :lost
#   - Add corresponding deal types: :new_business, :renewal, :expansion
#   - Add corresponding deal sources: e.g. :webinar, :referral, :outbound, :inbound,
#     :partner
#
# bin/rails g scaffold Deal remote_system_id:string name:string deal_stage:string \
#   last_contacted_at:timestamp lead_source:string notes:action_text \
#   priority_level:string deal_value:number expected_close_at:timestamp --pretend
Struct.new(
  'Deal',
  :remote_system_id,
  :name,
  :deal_stage,
  :created_at,
  :updated_at,
  :last_contacted_at,
  :lead_source,
  :notes,
  :priority_level,
  :deal_value,
  :expected_close_at,
  keyword_init: true
)
