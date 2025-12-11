# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  data               :jsonb
#  dataset            :string
#  name               :string
#  slug               :string
#  status             :string           not null
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_name              (name) UNIQUE
#  index_webhooks_on_slug              (slug) UNIQUE
#  index_webhooks_on_slug_and_dataset  (slug,dataset) UNIQUE WHERE (dataset IS NOT NULL)
#  index_webhooks_on_status            (status)
#
class WebhookSerializer < ActiveModel::Serializer
  attributes :id, :url, :slug, :status, :verification_token
end
