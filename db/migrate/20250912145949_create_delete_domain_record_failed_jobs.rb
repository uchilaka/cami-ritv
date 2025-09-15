# frozen_string_literal: true

# 20250912145949
class CreateDeleteDomainRecordFailedJobs < ActiveRecord::Migration[8.0]
  def change
    create_view :delete_domain_record_failed_jobs, materialized: true
  end
end
