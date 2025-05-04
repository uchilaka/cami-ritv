# frozen_string_literal: true

Fixtures::Users.new.invoke(:load, [], verbose: Rails.env.development?)

# Establish system account
larcity = Account.find_by_slug('larcity')

# Setup account access for users
test_user_1 = User.find_by_email('uche@larcity.com')
unless test_user_1.nil?
  if larcity.users.include?(test_user_1)
    puts "User #{test_user_1.email} already has access to account #{larcity.slug}"
  else
    larcity.users << test_user_1
  end
end
