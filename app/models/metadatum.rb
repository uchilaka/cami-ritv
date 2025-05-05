# frozen_string_literal: true

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
class Metadatum < ApplicationRecord
  has_and_belongs_to_many :accounts, join_table: 'accounts_metadata'
end
