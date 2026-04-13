# frozen_string_literal: true

json.array! @events, partial: 'webhooks/event', as: :event
