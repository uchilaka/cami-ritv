json.extract! event.serializable_hash,
              :id, :slug, :status, :created_at, :updated_at,
              :workspace_id, :workspace_name, :database_id, :remote_record_id,
              :url, :deal_url, :download_deal_url

json.metadatum event.metadatum.serializable_hash
