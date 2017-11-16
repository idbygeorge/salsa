# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

orgA = Organization.create(
  name: "localhost",
  slug: "localhost",
  default_account_filter: "FL17",
  lms_authentication_source: "",
  lms_authentication_key: "asdas",
  lms_authentication_id: "lkjlk"
)

orgB = Organization.create(
  name: "lvh.me",
  slug: "lvh.me",
  default_account_filter: "SU17",
  lms_authentication_source: "",
  lms_authentication_key: "asdasd",
  lms_authentication_id: "lkjlkl"
)
1.upto(4) do |d|
  if d > 2
    org = orgB
  else
    org = orgA
  end

  doc = Document.create(
    name:"Document #{d}",
    organization_id: org.id,
    lms_course_id: "CS",
    lms_published_at: DateTime.now,
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
