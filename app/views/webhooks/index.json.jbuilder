# frozen_string_literal: true

json.array! @webhooks, partial: 'webhooks/webhook', as: :webhook
