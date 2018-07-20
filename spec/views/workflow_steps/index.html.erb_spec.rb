require 'rails_helper'

RSpec.describe "workflow_steps/index", type: :view do
  before(:each) do
    assign(:workflow_steps, [
      WorkflowStep.create!(
        :slug => "Slug"
      ),
      WorkflowStep.create!(
        :slug => "Slug"
      )
    ])
  end

  it "renders a list of workflow_steps" do
    render
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
  end
end
