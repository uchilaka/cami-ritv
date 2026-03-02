# == Schema Information
#
# Table name: domain_records
#
#  id               :uuid             not null, primary key
#  name             :string
#  priority         :integer
#  status           :string           default("pending")
#  ttl              :integer          default(1800)
#  type             :string           not null
#  value            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  domain_name_id   :uuid             not null
#  vendor_record_id :string
#
# Indexes
#
#  index_domain_records_on_domain_and_name_and_type  (domain_name_id,name,type)
#  index_domain_records_on_domain_name_id            (domain_name_id)
#  index_domain_records_on_vendor_record_id          (vendor_record_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_name_id => domain_names.id)
#
Fabricator(:dns_record, from: 'Domain::Record') do
  type        { 'TXT' }
  name        { '@' }
  value       { SecureRandom.hex }
  ttl         { 1800 }
  domain_name fabricator: :domain_name
  status      { 'pending' }
end

Fabricator(:dns_a_record, from: :dns_record) do
  type        { 'A' }
  value       { Faker::Internet.ip_v4_address }
end
