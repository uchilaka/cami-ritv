# frozen_string_literal: true

module API
  module V2
    module CRM
      class AccountsController < ApplicationController
        include MaybeAccountSpecific

        load_account %i[update], optional: false, id_keys: %i[id]

        def update
          result = Zoho::API::Account.upsert(account)
          response_data = Zoho::API::Account.sync_callback!(result, account:)
          if response_data[:code] == 'SUCCESS'
            render json: response_data, status: :ok
          else
            render json: { errors: account.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
