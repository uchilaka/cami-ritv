# == Schema Information
#
# Table name: metadata
#
#  id              :uuid             not null, primary key
#  appendable_type :string
#  key             :string           not null
#  type            :string           default("Metadatum"), not null
#  value           :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  appendable_id   :uuid
#
# Indexes
#
#  index_for_zoho_oauth_serverinfo_metadata  (((value ->> 'region_alpha2'::text)))
#  index_metadata_on_appendable              (appendable_type,appendable_id)
#
Fabricator(:metadatum)

Fabricator(:notion_webhook_event_metadatum, from: :metadatum) do
  transient :variant # :deal_created, :deal_updated

  type 'Notion::WebhookEventMetadatum'
  variant { :deal_created }

  key do |attrs|
    case attrs[:variant]
    when :deal_created
      'notion.page.created'
    when :deal_updated
      'notion.page.properties_updated'
    else
      'notion.test_generic_event'
    end
  end

  value do |attrs|
    case attrs[:variant]
    when :deal_created
      {
        'type' => 'notion.page.created',
        'entity' => { 'id' => 'created-entity-id-123' },
        'database' => { 'id' => 'database-id-456' },
        'workspace_id' => 'workspace-id-789',
        'workspace_name' => 'Test Workspace',
        'subscription_id' => 'subscription-id-101112',
        'attempt_number' => 1,
      }
    when :deal_updated
      {
        'type' => 'notion.page.properties_updated',
        'entity' => { 'id' => 'updated-entity-id-123' },
        'database' => { 'id' => 'database-id-456' },
        'workspace_id' => 'updated-workspace-id-789',
        'workspace_name' => 'Updated Workspace',
        'subscription_id' => 'updated-subscription-id-101112',
        'attempt_number' => 2,
      }
    else
      {}
    end
  end
end
