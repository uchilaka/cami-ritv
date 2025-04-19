# frozen_string_literal: true

module LarCity
  class DeviseFailureApp < Devise::FailureApp
    def respond
      if request.format == :json
        http_auth
      else
        super
      end
    end
  end
end
