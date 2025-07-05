json.extract! event.serializable_hash,
              :id, :type, :slug, :created_at, :updated_at

json.metadatum event.metadatum.serializable_hash
