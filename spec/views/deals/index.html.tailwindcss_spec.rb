require 'rails_helper'

RSpec.describe "deals/index", type: :view do
  before(:each) do
    assign(:deals, [
      Deal.create!(
        account: nil,
        amount: "",
        priority: "Priority",
        stage: "Stage",
        type: "Type"
      ),
      Deal.create!(
        account: nil,
        amount: "",
        priority: "Priority",
        stage: "Stage",
        type: "Type"
      )
    ])
  end

  it "renders a list of deals" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Priority".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Stage".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Type".to_s), count: 2
  end
end
