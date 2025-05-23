# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'invoices/show', type: :view do
  let(:invoiceable) { Fabricate :account }
  let(:invoice) do
    Fabricate(
      :invoice,
      invoiceable:,
      invoice_number: 'INV-04',
      amount: '9.99',
      due_amount: '7.99',
      status: 'partially_paid'
    )
  end
  before(:each) do
    assign(:invoice, invoice)
  end

  pending 'A sent invoice should render the expected invoice item'
  pending 'A scheduled invoice should render the expected invoice item'
  pending 'A partially paid invoice should render the expected invoice item'
  pending 'A paid invoice should render the expected invoice item'
  pending 'A marked as paid invoice should render the expected invoice item'
  pending 'An unpaid invoice should render the expected invoice item'
  pending 'An overdue invoice should render the expected invoice item'

  it 'renders attributes in <p>' do
    render
    assert_select 'div>section>h1', text: 'Invoice #INV-04', count: 1
    expect(rendered).to match(/PARTIALLY_PAID/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/7.99/)
  end
end
