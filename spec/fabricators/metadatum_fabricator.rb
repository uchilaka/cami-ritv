# == Schema Information
#
# Table name: metadata
#
#  id         :uuid             not null, primary key
#  key        :string           not null
#  type       :string           default("Metadatum"), not null
#  value      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
Fabricator(:metadatum) do
end
