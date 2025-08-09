# frozen_string_literal: true

module Notion
  module DealProcessable
    extend ActiveSupport::Concern

    include ResultParseable

    included do
      protected

      # The process_deal method will create a Deal object from the deal_data.
      def process_deal(deal_data)
        @properties = deal_data['properties']

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
          integration: :notion,
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
    end
  end
end
