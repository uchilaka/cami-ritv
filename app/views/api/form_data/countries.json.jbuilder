# frozen_string_literal: true

json.array! @countries do |country|
  next if country[:dial_code].blank?

  json.partial!('api/form_data/country', country:)
end
