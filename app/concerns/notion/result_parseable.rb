# frozen_string_literal: true

module Notion
  module ResultParseable
    extend ActiveSupport::Concern

    attr_reader :properties

    included do
      protected

      # The following methods are responsible for parsing the different types of
      # properties that can be returned from the Notion API.
      #
      # These methods are called by the process_deal method.
      def parse_title(property)
        property['title']&.first&.dig('text', 'content')
      end

      def parse_select(property)
        property['select']&.dig('name')
      end

      def parse_date(property)
        property['date']&.dig('start')
      end

      def parse_email(property)
        property['email']
      end

      # TODO: Implement a method to parse people to a list of Struct::Contact
      #   from the Notion API deal data
      def parse_people(property)
        property['people']&.map { |person| person['name'] }&.join(', ')
      end

      def parse_phone_number(property)
        property['phone_number']
      end

      def parse_multi_select(property)
        property['multi_select']&.map { |option| option['name'] }
      end

      def parse_rich_text(property)
        property['rich_text']&.map { |text| text['plain_text'] }&.join
      end

      def parse_number(property)
        property['number']
      end

      def parse_formula(property)
        property['formula']&.dig('string') || property['formula']&.dig('number')
      end
    end
  end
end
