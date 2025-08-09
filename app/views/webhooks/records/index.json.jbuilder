# frozen_string_literal: true

json.array! @records, partial: 'webhooks/record', as: :record
