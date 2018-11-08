require 'rails_helper'

RSpec.describe "assignments/index", type: :view do
  before(:each) do
    assign(:assignments, [
      Assignment.create!(),
      Assignment.create!()
    ])
  end

  it "renders a list of assignments" do
    render
  end
end
