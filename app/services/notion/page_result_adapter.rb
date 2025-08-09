# frozen_string_literal: true

module Notion
  class PageResultAdapter
    def initialize(result)
      @result = result
    end

    def process_deal
      properties = @result['properties']

      remote_system_id = @result['id']
      name = parse_title(properties['Name'])
      deal_stage = parse_select(properties['Deal stage'])
      email = parse_email(properties['Email'])
      phone_number = parse_phone_number(properties['Phone number'])
      lead_source = parse_multi_select(properties['Lead source'])
      notes = parse_rich_text(properties['Notes'])
      created_at = Time.parse(@result['created_time'])
      updated_at = Time.parse(@result['last_edited_time'])
      last_contacted_at = parse_date(properties['Last contact date'])
      expected_close_at = parse_date(properties['Expected close date'])
      Struct::Deal.new(
        integration: :notion,
        remote_system_id:, name:, deal_stage:,
        last_contacted_at:, email:, phone_number:, lead_source:, notes:,
        priority_level: parse_select(properties['Priority level']),
        deal_value: parse_number(properties['Deal value']),
      )
    end
  end
end
