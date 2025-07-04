# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'invoices/edit', type: :view do
  let(:invoiceable) { Fabricate :account }
  let(:invoice) { Fabricate(:invoice, invoiceable:, amount: '9.99', due_amount: '9.99') }

  before(:each) do
    assign(:invoice, invoice)
  end

  it 'renders the edit invoice form' do
    render

    assert_select 'form[action=?][method=?]', invoice_path(invoice), 'post' do
      # assert_select 'input[name=?]', 'invoice[invoiceable_id]'
      #
      # assert_select 'input[name=?]', 'invoice[invoiceable_type]'
      #
      # assert_select 'input[name=?]', 'invoice[account_id]'
      #
      # assert_select 'input[name=?]', 'invoice[user_id]'
      #
      # assert_select 'input[name=?]', 'invoice[payments]'
      #
      # assert_select 'input[name=?]', 'invoice[links]'

      assert_select 'input[name=?]', 'invoice[invoice_number]'

      assert_select 'select[name=?]', 'invoice[status]'

      assert_select 'input[name=?]', 'invoice[amount]'

      assert_select 'input[name=?]', 'invoice[due_amount]'

      assert_select 'select[name=?]', 'invoice[currency_code]'

      assert_select 'trix-editor#invoice_notes'

      assert_select 'input[type="hidden"][name=?]', 'invoice[notes]'
    end
  end
end
