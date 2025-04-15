# frozen_string_literal: true

module LarCity
  module Errors
    class AccountConfirmationRequired < StandardError; end
    class ElevatedPrivilegesRequired < StandardError; end
    class Forbidden < StandardError; end
    class ResourceNotFound < StandardError; end
    class Unauthorized < StandardError; end
    class UnprocessableEntity < StandardError; end
    class InternalServerError < StandardError; end
    class Unsupported < StandardError; end
    class MissingRequiredModule < StandardError; end
    class UnsupportedOSError < StandardError; end
    class Unknown3rdPartyHostError < StandardError; end
    class UnexpectedDataResponseError < StandardError; end

    class IntegrationRequestFailed < StandardError
      attr_reader :status, :vendor

      def initialize(message, status:, vendor:)
        super(message)
        @status = status
        @vendor = vendor
      end
    end

    class InvalidInvoiceRecord < StandardError; end
  end
end
