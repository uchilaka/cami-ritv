# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                  :uuid             not null, primary key
#  discarded_at        :datetime
#  display_name        :string
#  email               :string
#  last_sent_to_crm_at :datetime
#  metadata            :jsonb
#  phone               :jsonb
#  readme              :text
#  slug                :string
#  status              :integer
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :uuid
#  remote_crm_id       :string
#  tax_id              :string
#
# Indexes
#
#  by_account_email_if_set                (email) UNIQUE NULLS NOT DISTINCT WHERE (email IS NOT NULL)
#  index_accounts_on_discarded_at         (discarded_at)
#  index_accounts_on_last_sent_to_crm_at  (last_sent_to_crm_at)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => accounts.id)
#
class Vendor < Account
  # See SO recommendation: https://stackoverflow.com/a/9463495/3726759
  def self.model_name
    Account.model_name
  end
end
