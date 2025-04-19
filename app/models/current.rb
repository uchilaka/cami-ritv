# frozen_string_literal: true

# CurrentAttributes API documentation https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :auth_provider, :account
  attribute :request_id, :user_agent, :ip_address
end
