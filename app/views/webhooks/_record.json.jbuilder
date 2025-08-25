case record.integration
when :notion
  json.partial! 'webhooks/notion/record', record:
else
  json.extract! record,
                :remote_system_id, :created_at, :updated_at
end
