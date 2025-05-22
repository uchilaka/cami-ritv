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
      info = result.dig('data', 0)
      code, action = info&.values_at('code', 'action')
      if code == 'SUCCESS'
        remote_crm_id = info.dig('details', 'id')
        case action
        when 'insert'
          account.update(remote_crm_id:)
        else
          Rails.logger.warn('An unsupported action occurred against a Zoho account record', result:)
        end
      else
        Rails.logger.error('Failed to upsert Zoho account record', result:)
      end
      result
    end
  end
end
