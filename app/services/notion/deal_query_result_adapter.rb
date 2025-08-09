# frozen_string_literal: true

module Notion
  # app/services/notion_adapter.rb
  class DealQueryResultAdapter
    # The NotionAdapter is responsible for processing the data from the Notion API.
    # It is initialized with the results from the Notion API and then the process_deals
    # method is called to process the data.
    def initialize(results)
      @results = results
    end

    # The process_deals method will iterate over the results and create a Deal object
    # for each result.
    def process_deals
      @results.map { |deal_data| process_deal(deal_data) }
    end

    private

    # The process_deal method will create a Deal object from the deal_data.
    def process_deal(deal_data)
      properties = deal_data['properties']

      property_mappings = {}

      # Available properties:
      # - Name
      # - Deal stage
      # - Last contact date
      # - Email
      # - Account owner
      # - Phone number
      # - Lead source
      # - Notes
      # - Priority level
      # - Deal value
      # - Decision maker
      # - Days since last contact
      # - Expected close date
      remote_system_id = deal_data['id']
      name = parse_title(properties['Name'])
      deal_stage = parse_select(properties['Deal stage'])
      email = parse_email(properties['Email'])
      phone_number = parse_phone_number(properties['Phone number'])
      lead_source = parse_multi_select(properties['Lead source'])
      notes = parse_rich_text(properties['Notes'])
      created_at = Time.parse(deal_data['created_time'])
      updated_at = Time.parse(deal_data['last_edited_time'])
      last_contacted_at = parse_date(properties['Last contact date'])
      expected_close_at = parse_date(properties['Expected close date'])
      Struct::Deal.new(
        remote_system_id:, name:, deal_stage:,
        last_contacted_at:, email:, phone_number:, lead_source:, notes:,
        # account_owner: parse_people(properties['Account owner']),
        # notes: parse_rich_text(properties['Notes']),
        priority_level: parse_select(properties['Priority level']),
        deal_value: parse_number(properties['Deal value']),
        # decision_maker: parse_people(properties['Decision maker']),
        # days_since_last_contact: parse_formula(properties['Days since last contact']),
        expected_close_at:, created_at:, updated_at:
      )
    end

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
