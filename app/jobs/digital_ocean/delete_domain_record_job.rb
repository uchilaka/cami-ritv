# frozen_string_literal: true

# require 'active_job'

module DigitalOcean
  class DeleteDomainRecordJob < ApplicationJob
    queue_as :yeet

    def perform(id, domain:, access_token: nil, pretend: false)
      # Check if there's a pending failed execution

      # pending_failed_jobs = SolidQueue::Job.where(
      #   "arguments ->> 0 = ? AND failed_at IS NOT NULL AND retry_count < max_retries",
      #   id.to_s
      # )

      # Use Arel to get table name for SolidQueue::FailedExecution
      # failed_executions_table = SolidQueue::FailedExecution.arel_table

      # Query solid queue jobs for any jobs with the same first argument
      # value (id) that have any SolidQueue::FailedExecution records associated
      # with them. This is to avoid duplicate jobs being enqueued if a previous
      # job failed and is pending retry.
      jobs_schema = SolidQueue::Job.arel_table.name.to_s.to_sym
      failed_execution_schema = SolidQueue::FailedExecution.arel_table.name.to_s.to_sym

      failed_executions =
        SolidQueue::FailedExecution.joins(
          "INNER JOIN #{jobs_schema} ON #{failed_execution_schema}.job_id = #{jobs_schema}.id"
        ).where("(#{jobs_schema}.arguments->>0)::numeric = ?", id)


      failed_jobs = SolidQueue::Job.joins(
        "INNER JOIN #{failed_execution_schema} ON #{jobs_schema}.id = #{failed_execution_schema}.job_id"
      ).where('(arguments->>0)::numeric = ?', id)


      # SolidQueue::FailedExecution
      DigitalOcean::API.delete_domain_record(id, domain:, access_token:, pretend:)
    end

    private

    def client(access_token: nil)
      @client ||= DigitalOcean::API.http_client(access_token:)
    end
  end
end
