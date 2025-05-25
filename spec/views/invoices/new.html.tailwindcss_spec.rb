# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'invoices/new', type: :view do
  let(:user) { Fabricate :user }
  let(:invoice) { Fabricate :invoice, invoiceable: user }

  before(:each) do
    sign_in user
    allow(view).to receive(:current_user).and_return(user)
    assign(:invoice, Fabricate.build(:invoice, invoiceable: user))
  end

  it 'renders new invoice form' do
    render

    assert_select 'form[action=?][method=?]', invoices_path, 'post' do
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
