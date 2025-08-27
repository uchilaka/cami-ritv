require 'rails_helper'

RSpec.describe "deals/edit", type: :view do
  let(:deal) {
    Deal.create!(
      account: nil,
      amount: "",
      priority: "MyString",
      stage: "MyString",
      type: ""
    )
  }

  before(:each) do
    assign(:deal, deal)
  end

  it "renders the edit deal form" do
    render

    assert_select "form[action=?][method=?]", deal_path(deal), "post" do

      assert_select "input[name=?]", "deal[account_id]"

      assert_select "input[name=?]", "deal[amount]"

      assert_select "input[name=?]", "deal[priority]"

      assert_select "input[name=?]", "deal[stage]"

      assert_select "input[name=?]", "deal[type]"
    end
  end
end
