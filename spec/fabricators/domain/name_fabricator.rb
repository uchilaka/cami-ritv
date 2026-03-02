# == Schema Information
#
# Table name: domain_names
#
#  id         :uuid             not null, primary key
#  hostname   :string           not null
#  status     :string           default("active")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_domains_on_name  (hostname) UNIQUE
#
Fabricator(:domain_name, from: 'Domain::Name') do
  hostname  { Faker::Internet.domain_name }
  status    { 'active' }
end
