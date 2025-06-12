json.extract! webhook, :id, :url, :verification_token, :created_at, :updated_at
json.url webhook_url(webhook, format: :json)
