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
class AccountSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :slug, :email,
             :status, :type, :tax_id, :notes_as_html,
             :created_at, :updated_at, :actions,
             :actions_list, :parent_id

  def phone
    return nil unless object.phone.present?

    object.phone['value']
  end

  # Read more on rendering rich text content:
  # https://guides.rubyonrails.org/action_text_overview.html#rendering-rich-text-content
  def notes_as_html
    object.readme.to_s
  end

  def actions
    object.actions
  end

  def actions_list
    object.actions_as_list
  end
end
