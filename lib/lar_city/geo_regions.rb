# frozen_string_literal: true

module LarCity
  module GeoRegions
    class << self
      def lookup(region_or_country_iso3166, attr_name = nil)
        return nil if region_or_country_iso3166.blank?

        country = countries[region_or_country_iso3166.to_s.upcase]
        return country if attr_name.nil? || country.nil?

        country[attr_name.to_sym]
      end

      def countries
        @countries ||=
          Rails
            .application
            .config_for(:countries)
            .each_with_object({}) do |value, obj|
              obj[value[:'alpha-2']] = {
                name: country_formatted_name(value[:name]),
                alpha_2: value[:'alpha-2'],
                country_code: value[:'country-code'],
              }
            end
      end

      private

      def country_formatted_name(name)
        return name if name.exclude?(',') || /Taiwan|Saint Helena/.match?(name)

        name.split(',').map(&:strip).reverse.join(' ')
      end
    end
  end
end
