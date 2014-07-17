require 'rails_helper'

RSpec.describe Document, :type => :model do
  it "generates random IDs when creating" do
  	document = Document.create!(name: 'New Doc')

  	expect([document[:edit_id], document[:view_id], document[:template_id]]).to all match(/[a-z]{30}/)
  end

  it "can regenerate new random IDs" do
  	document = Document.create!(name: 'New Doc')
  	edit_id = document[:edit_id]
  	view_id = document[:view_id]
  	template_id = document[:template_id]

  	document.reset_ids

  	expect(document[:edit_id]).not_to eq(edit_id)
  	expect(document[:view_id]).not_to eq(view_id)
  	expect(document[:template_id]).not_to eq(template_id)
  	
  	expect([document[:edit_id], document[:view_id], document[:template_id]]).to all match(/[a-z]{30}/)
  end
end
