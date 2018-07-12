require 'rails_helper'

RSpec.describe "workflow_steps/new", type: :view do
  before(:each) do
    assign(:workflow_step, WorkflowStep.new(
      :slug => "MyString"
    ))
  end

  it "renders new workflow_step form" do
    render

    assert_select "form[action=?][method=?]", workflow_steps_path, "post" do

      assert_select "input[name=?]", "workflow_step[slug]"
    end
  end
end
