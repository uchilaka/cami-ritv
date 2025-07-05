json.extract! event.serializable_hash,
              :id, :slug, :status, :created_at, :updated_at,
              :workspace_id, :workspace_name, :database_id, :remote_record_id

json.metadatum event.metadatum.serializable_hash
