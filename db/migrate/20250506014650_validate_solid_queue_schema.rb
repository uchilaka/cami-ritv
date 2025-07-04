# frozen_string_literal: true

# 20250506014650
class ValidateSolidQueueSchema < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key 'solid_queue_blocked_executions', 'solid_queue_jobs'
    validate_foreign_key 'solid_queue_claimed_executions', 'solid_queue_jobs'
    validate_foreign_key 'solid_queue_failed_executions', 'solid_queue_jobs'
    validate_foreign_key 'solid_queue_ready_executions', 'solid_queue_jobs'
    validate_foreign_key 'solid_queue_recurring_executions', 'solid_queue_jobs'
    validate_foreign_key 'solid_queue_scheduled_executions', 'solid_queue_jobs'
  end
end
