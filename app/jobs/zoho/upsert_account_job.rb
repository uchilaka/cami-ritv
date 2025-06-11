# frozen_string_literal: true

module Zoho
  class UpsertAccountJob < ApplicationJob
    queue_as :critical

    attr_accessor :account

    def perform(id)
      @account = Account.find_by(id:)
      if account.blank?
        Rails.logger.error('Could not find account record', id:)
        return
      end

      Rails.logger.info('Upserting Zoho account record', id:)
      result = Zoho::API::Account.upsert(account)
      Zoho::API::Account.sync_callback!(result, account:)
      result
    end
  end
end
