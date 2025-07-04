# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  data               :jsonb
#  slug               :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_slug  (slug) UNIQUE
#
class Webhook < ApplicationRecord
  extend FriendlyId

  encrypts :verification_token, deterministic: true

  has_rich_text :readme

  friendly_id :slug, use: :slugged

  has_many :generic_events, as: :eventable, dependent: :nullify

  validates :slug, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :verification_token, presence: true

  def url
    "https://#{hostname}/api/v2/webhooks/#{slug}/events"
  end

  protected

  def hostname
    ENV.fetch('HOSTNAME')
  end
end
