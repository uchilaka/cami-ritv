require 'rails_helper'

RSpec.describe "deals/show", type: :view do
  before(:each) do
    assign(:deal, Deal.create!(
      account: nil,
      amount: "",
      priority: "Priority",
      stage: "Stage",
      type: "Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Priority/)
    expect(rendered).to match(/Stage/)
    expect(rendered).to match(/Type/)
  end
end
