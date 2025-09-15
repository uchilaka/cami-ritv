# frozen_string_literal: true

# == Schema Information
#
# Table name: delete_domain_record_failed_jobs
#
#  id              :bigint
#  arguments       :jsonb
#  class_name      :string
#  concurrency_key :string
#  error_backtrace :text             is an Array
#  error_message   :text
#  exception       :jsonb
#  finished_at     :datetime
#  priority        :integer
#  queue_name      :string
#  scheduled_at    :datetime
#  active_job_id   :string
#  record_id       :bigint
#
class DeleteDomainRecordFailedJob < ApplicationRecord
end
