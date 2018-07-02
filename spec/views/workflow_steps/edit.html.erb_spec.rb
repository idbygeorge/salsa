require 'rails_helper'

RSpec.describe "workflow_steps/edit", type: :view do
  before(:each) do
    @workflow_step = assign(:workflow_step, WorkflowStep.create!(
      :slug => "MyString"
    ))
  end

  it "renders the edit workflow_step form" do
    render

    assert_select "form[action=?][method=?]", workflow_step_path(params[:slug]@workflow_step), "post" do

      assert_select "input[name=?]", "workflow_step[slug]"
    end
  end
end
