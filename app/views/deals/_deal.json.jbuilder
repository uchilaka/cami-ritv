json.extract! deal, :id, :account_id, :amount, :expected_close_at, :last_contacted_at, :priority, :stage, :type, :created_at, :updated_at
json.url deal_url(deal, format: :json)
