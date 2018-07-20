require 'rails_helper'

RSpec.describe "workflow_steps/show", type: :view do
  before(:each) do
    @workflow_step = assign(:workflow_step, WorkflowStep.create!(
      :slug => "Slug"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Slug/)
  end
end
