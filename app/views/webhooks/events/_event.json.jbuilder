json.extract! event.serializable_hash,
              :type, :created_at, :updated_at

json.metadatum event.metadatum.serializable_hash
