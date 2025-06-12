# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  readme             :text
#  slug               :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_slug  (slug) UNIQUE
#
class WebhookSerializer < ActiveModel::Serializer
  attributes :id, :url, :verification_token
end
