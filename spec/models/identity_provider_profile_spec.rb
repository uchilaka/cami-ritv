# frozen_string_literal: true

# == Schema Information
#
# Table name: identity_provider_profiles
#
#  id           :uuid             not null, primary key
#  display_name :string
#  email        :string
#  family_name  :string           default("")
#  given_name   :string           default("")
#  image_url    :string
#  metadata     :jsonb
#  provider     :string
#  uid          :string
#  verified     :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_identity_provider_profiles_on_email_and_provider    (email,provider) UNIQUE
#  index_identity_provider_profiles_on_uid_and_provider      (uid,provider) UNIQUE
#  index_identity_provider_profiles_on_user_id               (user_id)
#  index_identity_provider_profiles_on_user_id_and_provider  (user_id,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe IdentityProviderProfile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
