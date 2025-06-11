class WebhookSerializer < ActiveModel::Serializer
  attributes :id, :url, :verification_token
end
