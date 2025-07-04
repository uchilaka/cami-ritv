# frozen_string_literal: true

Fixtures::Accounts.new.invoke(:load, [], verbose: Rails.env.development?)
