# == Schema Information
#
# Table name: webhooks
#
#  id                 :uuid             not null, primary key
#  url                :string
#  verification_token :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
Fabricator(:webhook) do
  url                "MyString"
  verification_token "MyString"
end
