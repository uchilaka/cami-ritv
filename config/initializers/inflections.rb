# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# Customizing inflections https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#customizing-inflections
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # inflect.acronym "RESTful"
  inflect.acronym 'URL'
  inflect.acronym 'API'
  inflect.acronym 'DDNS'
  inflect.acronym 'CAMI'
  inflect.acronym 'CLI'
  inflect.acronym 'HTML'
  inflect.acronym 'PII'
  inflect.acronym 'SSL'
  inflect.acronym 'VAT'
  inflect.acronym 'CRM'
end
