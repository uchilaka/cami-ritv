# == Schema Information
#
# Table name: deals
#
#  id                :uuid             not null, primary key
#  amount            :money
#  expected_close_at :datetime
#  last_contacted_at :datetime
#  priority          :string
#  stage             :string           default("discovery"), not null
#  type              :string           default("Deal"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :uuid
#
# Indexes
#
#  index_deals_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'rails_helper'

RSpec.describe Deal, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
