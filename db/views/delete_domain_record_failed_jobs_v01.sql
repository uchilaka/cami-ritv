SELECT j.id,
       j.class_name,
       j.queue_name,
       j.priority,
       j.active_job_id,
       j.scheduled_at,
       j.finished_at,
       j.concurrency_key,
       fx.error::jsonb as exception,
       (fx.error::jsonb)->>'message' as error_message,
       ARRAY(SELECT jsonb_array_elements_text(fx.error::jsonb -> 'backtrace')) as error_backtrace,
       ((j.arguments::jsonb)->>'arguments')::jsonb as arguments,
       (((j.arguments::jsonb)->>'arguments')::jsonb->>0)::bigint as record_id
-- , (j.arguments::jsonb)->>arguments::anyarray[1] as record_id
FROM solid_queue_failed_executions fx
       INNER JOIN solid_queue_jobs j ON fx.job_id = j.id
WHERE j.class_name = 'DigitalOcean::DeleteDomainRecordJob';
