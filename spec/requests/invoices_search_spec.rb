# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Invoice Search API', type: :request, feature: :invoicing do
  describe 'POST /invoices/search' do
    let(:user) { Fabricate :user, email: Faker::Internet.email(name: 'logistics') }
    let(:other_user) { Fabricate :user, email: Faker::Internet.email(name: 'catering') }

    let(:invoicer) { { 'email' => 'accounts@larcity.com' } }
    let(:invoice_data) do
      [
        [account.email, 20, 'paid', '2020-08-25'],
        [account.email, 149.99, 'draft', '2021-11-25'],
        [account.email, 129.99, 'draft', '2021-12-07'],
        [other_account.email, 129.99, 'draft', '2021-12-07'],
        [account.email, 99.99, 'sent', '2021-12-14'],
        [account.email, 79.99, 'paid', '2021-12-15'],
        [other_account.email, 109.99, 'paid', '2021-12-04'],
        [account.email, 149.99, 'paid', '2022-12-16'],
        [account.email, 185.99, 'partially_paid', '2023-12-17'],
        [account.email, 99.99, 'sent', '2024-12-18'],
        [other_account.email, 74.99, 'sent', '2024-12-18'],
      ]
    end

    let!(:account) do
      Fabricate(:account, display_name: 'Fivr Solutions LTD', email: user.email, users: [user])
    end
    let!(:other_account) do
      Fabricate(:account, display_name: 'Rita Baked Goods', email: other_user.email, users: [other_user])
    end

    before do
      invoice_data.each do |email, amount, status, issued_at|
        invoiceable = Account.find_by_email(email)
        Fabricate(:invoice, invoiceable:, amount:, status:, created_at: issued_at, issued_at:)
      end
    end

    path '/invoices/search.json' do
      shared_examples 'invoice search with a query string' do |q, status, expected_count|
        context "where status = #{status.upcase} and q = \"#{q}\"" do
          let(:f) do
            [{ 'field' => 'status', 'value' => status.upcase }]
          end
          let(:s) do
            [
              { 'field' => 'dueAt', 'direction' => 'desc' },
              { 'field' => 'account', 'direction' => 'desc' },
            ]
          end
          let(:search_params) { { mode: 'array', q:, s:, f: } }

          run_test! do |response|
            expect(response.body).not_to be_nil
            data = JSON.parse(response.body)
            expect(data.size).to eq(expected_count)
          end
        end
      end

      shared_examples 'invoice search without a query string' do |status, expected_count|
        context "where status is #{status.upcase}" do
          let(:q) { nil }
          let(:f) do
            [{ 'field' => 'status', 'value' => status.upcase }]
          end
          let(:s) do
            [
              { 'field' => 'dueAt', 'direction' => 'desc' },
              { 'field' => 'account', 'direction' => 'desc' },
            ]
          end
          let(:search_params) { { mode: 'array', q:, s:, f: } }
          let(:data) { JSON.parse(response.body) }

          run_test! do |response|
            # Returns a response body
            expect(response.body).not_to be_nil
            # Returns the expected number of invoices
            expect(data.size).to eq(expected_count)

            unless user.has_role?(:admin)
              # Only returns invoices accessible by the authorized user
              data.each do |invoice|
                account = Account.find_by_id(invoice.dig('account', 'id'))
                expect(account.members).to include(user)
              end
            end
          end
        end
      end

      post 'Retrieves all invoices' do
        tags 'Invoices'
        consumes 'application/json'
        produces 'application/json'

        parameter name: :search_params, in: :body, schema: {
          oneOf: [
            { '$ref': '#/components/schemas/invoice_search_params' },
            { '$ref': '#/components/schemas/invoice_search_params_with_array_mode' },
          ]
        }

        response '200', 'invoices found' do
          schema type: :array,
                 items: { '$ref' => '#/components/schemas/invoice' }

          before { sign_in user }

          it { expect(account.members).to include(user) }

          context 'with query string matching email address of authorized account' do
            it_should_behave_like 'invoice search with a query string', 'logistics', 'PAID', 3
            it_should_behave_like 'invoice search with a query string', 'logistics', 'SENT', 2
          end

          context 'with query string matching email display name of authorized account' do
            it_should_behave_like 'invoice search with a query string', 'fivr', 'PAID', 3
            it_should_behave_like 'invoice search with a query string', 'fivr', 'SENT', 2
          end

          context 'with query string matching email address of unauthorized account' do
            it_should_behave_like 'invoice search with a query string', 'catering', 'PAID', 0
            it_should_behave_like 'invoice search with a query string', 'catering', 'SENT', 0
          end

          context 'with query string matching display name of unauthorized account' do
            it_should_behave_like 'invoice search with a query string', 'rita', 'PAID', 0
            it_should_behave_like 'invoice search with a query string', 'rita', 'SENT', 0
          end

          context 'without query string (should exclude unauthorized accounts in results)' do
            it_should_behave_like 'invoice search without a query string', 'PAID', 3
            it_should_behave_like 'invoice search without a query string', 'SENT', 2
          end

          context 'with an admin account' do
            before { user.add_role :admin }

            it { expect(user.has_role?(:admin)).to be true }
            it_should_behave_like 'invoice search with a query string', 'logistics', 'PAID', 3
            it_should_behave_like 'invoice search with a query string', 'logistics', 'SENT', 2
            it_should_behave_like 'invoice search with a query string', 'fivr', 'PAID', 3
            it_should_behave_like 'invoice search with a query string', 'fivr', 'SENT', 2
            it_should_behave_like 'invoice search with a query string', 'catering', 'PAID', 1
            it_should_behave_like 'invoice search with a query string', 'catering', 'SENT', 1
            it_should_behave_like 'invoice search with a query string', 'rita', 'PAID', 1
            it_should_behave_like 'invoice search with a query string', 'rita', 'SENT', 1
            it_should_behave_like 'invoice search without a query string', 'PARTIALLY_PAID', 1
            it_should_behave_like 'invoice search without a query string', 'PAID', 4
            it_should_behave_like 'invoice search without a query string', 'SENT', 3
          end
        end
      end
    end
  end
end
