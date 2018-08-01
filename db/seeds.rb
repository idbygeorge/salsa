# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

orgs = []
orgs.push Organization.create(
  name: "localhost",
  slug: "localhost",
  default_account_filter: '{"account_filter":"FL17"}',
  lms_authentication_source: "",
  lms_authentication_key: "asdas",
  lms_authentication_id: "lkjlk"
)

orgs.push Organization.create(
  name: "lvh.me",
  slug: "lvh.me",
  default_account_filter: '{"account_filter":"SU17"}',
  lms_authentication_source: "",
  lms_authentication_key: "asdasd",
  lms_authentication_id: "lkjlkl"
)

file_paths = Dir.glob("app/views/instances/default/*.erb")
orgs.each do |org|
  wfsteps = []
  4.downto(1) do |d|
    wfs = WorkflowStep.new(
      organization_id: org.id,
      name: "Step #{d}",
      slug: "step_#{d}",

    )
    wfs.next_workflow_step_id = wfsteps.last.id if wfsteps.last
    wfs.start_step = true if d==1
    wfs.end_step = true if d==4
    wfs.save
    wfsteps.push wfs
  end
  file_paths.each do |file_path|
    Component.create(
      organization_id: org.id,
      name: File.basename(file_path, ".html.erb"),
      slug: File.basename(file_path, ".html.erb")[1..-1],
      description: "",
      category: "document",
      layout: File.read(file_path),
      format: File.extname(file_path).delete('.')
    )
  end

  1.upto(4) do |d|
    doc = Document.create(
      name:"Document #{d}",
      organization_id: org.id,
      lms_course_id: "CS#{d}",
      lms_published_at: DateTime.now,
      created_at: DateTime.now.ago(10),
      updated_at: DateTime.now,

    )
    #Create document_meta's
    DocumentMeta.create(
      document_id: doc.id,
      key: "account_id",
      value: "CLS",
      lms_organization_id: "asdasfsgsadf",
      lms_course_id: doc.lms_course_id,
      root_organization_id: org[:id].to_s
    )
    DocumentMeta.create(
      document_id: doc.id,
      key: "name",
      value: "FL17",
      lms_organization_id: "asdasfsgsadf",
      lms_course_id: doc.lms_course_id,
      root_organization_id: org[:id].to_s
    )
    DocumentMeta.create(
      document_id: doc.id,
      key: "total_students",
      value: "23",
      lms_organization_id: "asdasfsgsadf",
      lms_course_id: doc.lms_course_id,
      root_organization_id: org[:id].to_s
    )
    DocumentMeta.create(
      document_id: doc.id,
      key: "enrollment_term_id",
      value: doc.term_id,
      lms_organization_id: "asdasfsgsadf",
      lms_course_id: doc.lms_course_id,
      root_organization_id: org[:id].to_s
    )
  end
end
