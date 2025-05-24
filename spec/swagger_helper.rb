# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'accounts.larcity.local'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
          },
          basic_auth: {
            type: :http,
            scheme: :basic,
          }
        },
        schemas: {
          account: {
            type: :object,
            properties: {
              id: { type: :string },
              displayName: { type: :string },
              email: { type: :string },
              status: { type: :string },
              taxId: { type: :string, nullable: true },
              type: { type: :string },
            },
            required: %i[id displayName email status]
          },
          contact: {
            type: :object,
            properties: {
              displayName: { type: :string },
              familyName: { type: :string },
              givenName: { type: :string },
              email: { type: :string },
              type: { type: :string },
            },
            required: %i[displayName email]
          },
          money: {
            type: :object,
            properties: {
              currencyCode: { type: :string },
              formattedValue: { type: :string },
              value: { type: :number },
              valueInCents: { type: :integer },
            },
            required: %i[currencyCode formattedValue value valueInCents]
          },
          invoice: {
            type: :object,
            properties: {
              id: { type: :string },
              account: {
                '$ref' => '#/components/schemas/account',
                nullable: true
              },
              contacts: {
                type: :array,
                items: { '$ref' => '#/components/schemas/contact' }
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
            required: %i[id account contacts status invoiceNumber currencyCode createdAt dueAt amount dueAmount]
          },
          invoice_search_params: {
            type: :object,
            properties: {
              q: { type: :string, nullable: true },
              mode: { type: :string, nullable: true },
              f: {
                type: :object,
                nullable: true,
                properties: {
                  field: { type: :string },
                  value: { type: :string }
                }
              },
              s: {
                type: :object,
                nullable: true,
                properties: {
                  field: { type: :string },
                  direction: { type: :string }
                }
              }
            }
          },
          invoice_search_params_with_array_mode: {
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
                    value: { type: :string }
                  }
                }
              },
              s: {
                type: :array,
                nullable: true,
                items: {
                  type: :object,
                  properties: {
                    field: { type: :string },
                    direction: { type: :string }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
