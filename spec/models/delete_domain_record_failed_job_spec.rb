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
require 'rails_helper'

RSpec.describe DeleteDomainRecordFailedJob, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
