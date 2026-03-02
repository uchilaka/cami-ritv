# frozen_string_literal: true

module Domain
  STATUSES = %w[active inactive pending suspended error retired].freeze

  def self.table_name_prefix
    'domain_'
  end
end
