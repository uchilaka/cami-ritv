# frozen_string_literal: true

module Swagger
  module Schemas
    def self.all
      {
        notion_entity:,
        notion_block:,
        notion_event:,
        account:,
        contact:,
        money:,
        invoice:,
        invoice_search_params:,
        invoice_search_params_with_array_mode:,
        country:,
        country_mapped:,
      }
    end

    def self.notion_entity
      {
        type: :object,
        properties: {
          id: { type: :string },
          type: {
            type: :string,
            pattern: '^(page|database|person|block)$',
          },
        },
        required: %w[id type],
      }
    end

    def self.notion_block
      {
        '$ref' => '#/components/schemas/notion_entity',
      }
    end

    def self.notion_event
      {
        type: :object,
        properties: {
          id: { type: :string },
          timestamp: { type: :string, format: 'date-time' },
          workspace_id: { type: :string },
          workspace_name: { type: :string },
          subscription_id: { type: :string },
          integration_id: { type: :string },
          attempt_number: { type: :integer },
          authors: {
            type: :array,
            items: { '$ref' => '#/components/schemas/notion_entity' },
          },
          data: {
            type: :object,
            properties: {
              parent: {
                '$ref' => '#/components/schemas/notion_entity',
              },
              updated_blocks: {
                type: :array,
                nullable: true,
                items: {
                  '$ref' => '#/components/schemas/notion_block',
                },
              },
            },
            required: %w[parent],
          },
          type: {
            type: :string,
            pattern: '^(page.created|page.content_updated|page.deleted|page.moved|page.properties_updated|database.content_updated|database.schema_updated|database.deleted)$',
          },
          entity: {
            '$ref' => '#/components/schemas/notion_entity',
          },
        },
        required: %w[id data type integration_id attempt_number],
      }
    end

    def self.account
      {
        type: :object,
        properties: {
          id: { type: :string },
          displayName: { type: :string },
          email: { type: :string },
          status: { type: :string },
          taxId: { type: :string, nullable: true },
          type: { type: :string },
        },
        required: %i[id displayName email status],
      }
    end

    def self.contact
      {
        type: :object,
        properties: {
          displayName: { type: :string },
          familyName: { type: :string },
          givenName: { type: :string },
          email: { type: :string },
          type: { type: :string },
        },
        required: %i[displayName email],
      }
    end

    def self.money
      {
        type: :object,
        properties: {
          currencyCode: { type: :string },
          formattedValue: { type: :string },
          value: { type: :number },
          valueInCents: { type: :integer },
        },
        required: %i[currencyCode formattedValue value valueInCents],
      }
    end

    def self.invoice
      {
        type: :object,
        properties: {
          id: { type: :string },
          account: {
            '$ref' => '#/components/schemas/account',
            nullable: true,
          },
          contacts: {
            type: :array,
            items: { '$ref' => '#/components/schemas/contact' },
          },
          status: { type: :string },
          invoiceNumber: { type: :string },
          currencyCode: { type: :string },
          createdAt: { type: :string, format: 'date-time' },
          dueAt: { type: :string, format: 'date-time', nullable: true },
          paidAt: { type: :string, format: 'date-time', nullable: true },
          amount: { '$ref' => '#/components/schemas/money' },
          dueAmount: { '$ref' => '#/components/schemas/money' },
          paymentVendorURL: { type: :string },
        },
        required: %i[id account contacts status invoiceNumber currencyCode createdAt dueAt amount dueAmount],
      }
    end

    def self.invoice_search_params
      {
        type: :object,
        properties: {
          q: { type: :string, nullable: true },
          mode: { type: :string, nullable: true },
          f: {
            type: :object,
            nullable: true,
            properties: {
              field: { type: :string },
              value: { type: :string },
            },
          },
          s: {
            type: :object,
            nullable: true,
            properties: {
              field: { type: :string },
              direction: { type: :string },
            },
          },
        },
      }
    end

    def self.invoice_search_params_with_array_mode
      {
        type: :object,
        properties: {
          q: { type: :string, nullable: true },
          mode: { type: :string, nullable: true },
          f: {
            type: :array,
            nullable: true,
            items: {
              type: :object,
              properties: {
                field: { type: :string },
                value: { type: :string },
              },
            },
          },
          s: {
            type: :array,
            nullable: true,
            items: {
              type: :object,
              properties: {
                field: { type: :string },
                direction: { type: :string },
              },
            },
          },
        },
      }
    end

    def self.country
      {
        type: :object,
        properties: {
          id: { type: :string },
          name: { type: :string },
          alpha2: { type: :string },
          dial_code: { type: :string, nullable: true },
        },
        required: %w[id name alpha2 dial_code],
      }
    end

    def self.country_mapped
      {
        type: :object,
        properties: {
          id: { type: :string },
          name: { type: :string },
          alpha2: { type: :string },
          dialCode: { type: :string, nullable: true },
        },
        required: %w[id name alpha2 dialCode],
      }
    end
  end
end
