# frozen_string_literal: true

json.extract! account.serializable_hash, :id, :slug, :email, :display_name,
              :status, :type, :tax_id, :email, :created_at, :updated_at, :actions,
              :actions_list, :parent_id

json.readme do
  json.html account.readme.to_s
  json.plaintext account.readme.to_plain_text
end

json.phone account.phone['value'] if account.phone.present? && account.phone['value'].present?

json.url account_url(account, format: :json)
json.is_vendor account.has_role?(:vendor)

# json.invoices account.invoices, partial: 'invoices/invoice', as: :invoice
