# frozen_string_literal: true

json.extract! record,
              :remote_system_id,
              :name,
              :email,
              :phone_number,
              :deal_stage,
              :created_at,
              :updated_at,
              :priority_level,
              :deal_value,
              :expected_close_at
