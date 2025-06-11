# frozen_string_literal: true

class Webhook < ApplicationRecord
  encrypts :verification_token

  validates :url,
            presence: true,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: t('validators.errors.invalid_url'),
            }
  validates :verification_token, presence: true
end
