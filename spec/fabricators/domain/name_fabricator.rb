# == Schema Information
#
# Table name: domain_names
#
#  id         :uuid             not null, primary key
#  hostname   :string           not null
#  status     :string           default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vendor_id  :uuid
#
# Indexes
#
#  index_domain_names_on_vendor_id  (vendor_id)
#  index_domains_on_name            (hostname) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (vendor_id => accounts.id)
#
Fabricator(:domain_name, from: 'Domain::Name') do
  hostname  { Faker::Internet.domain_name }
  status    { 'pending' }
  vendor    fabricator: :account
end
