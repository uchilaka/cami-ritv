# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  url                :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Webhook < ApplicationRecord
  encrypts :verification_token, deterministic: true

  validates :url,
            presence: true,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: I18n.t('validators.errors.invalid_url'),
            }
  validates :verification_token, presence: true
end
