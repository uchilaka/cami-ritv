# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  data               :jsonb
#  slug               :string
#  status             :string           default("pending_review"), not null
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_webhooks_on_slug    (slug) UNIQUE
#  index_webhooks_on_status  (status)
#
class Webhook < ApplicationRecord
  extend FriendlyId

  include AASM

  store_accessor :data, %i[integration_id integration_name]

  encrypts :verification_token, deterministic: true

  has_rich_text :readme

  friendly_id :slug, use: :slugged

  has_many :generic_events, as: :eventable, dependent: :nullify

  aasm column: :status do
    state :pending_review, initial: true
    state :active
    state :disabled

    # TODO: implement callback to (async) job to send a notification to the admin user to review the webhook.
    #   See callback example(s): https://github.com/aasm/aasm?tab=readme-ov-file#callbacks
    event :start_review do
      transitions from: %i[active disabled], to: :pending_review
    end

    event :disable do
      transitions from: :active, to: :disabled
    end

    event :enable do
      transitions from: %i[pending_review disabled], to: :active, guard: :verified?
    end
  end

  validates :slug,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 64 }
  validates :verification_token, presence: true

  def url
    "https://#{hostname}/api/v2/webhooks/#{slug}/events"
  end

  protected

  def hostname
    ENV.fetch('HOSTNAME')
  end

  def verified?
    verification_token.present?
  end
end
