require 'rails_helper'

RSpec.describe "deals/new", type: :view do
  before(:each) do
    assign(:deal, Deal.new(
      account: nil,
      amount: "",
      priority: "MyString",
      stage: "MyString",
      type: ""
    ))
  end

  it "renders new deal form" do
    render

    assert_select "form[action=?][method=?]", deals_path, "post" do

      assert_select "input[name=?]", "deal[account_id]"

      assert_select "input[name=?]", "deal[amount]"

      assert_select "input[name=?]", "deal[priority]"

      assert_select "input[name=?]", "deal[stage]"

      assert_select "input[name=?]", "deal[type]"
    end
  end
end
