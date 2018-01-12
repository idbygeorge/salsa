FactoryBot.define do  
  sequence :lms_course_id do
  

  #document factory
  factory :document do
    name: "Document",
    organization_id: organization.id,
    lms_course_id: "CS",
    lms_published_at: DateTime.now,
    created_at: DateTime.now.ago(10),
    updated_at: DateTime.now,
    organization
      
  end
  # document meta factory
  factory :document_meta do
    document_id: document.id,
    key: "account_id",
    value: "CLS",
    lms_organization_id: "asdasfsgsadf",
    lms_course_id: document.lms_course_id,
    root_organization_id: organization[:id].to_s
    organization
    document
  end
  factory :document_meta do
    document_id: doc.id,
    key: "name",
    value: "FL17",
    lms_organization_id: "asdasfsgsadf",
    lms_course_id: doc.lms_course_id,
    root_organization_id: org[:id].to_s
  end
  factory :document_meta do
    document_id: doc.id,
    key: "total_students",
    value: "23",
    lms_organization_id: "asdasfsgsadf",
    lms_course_id: doc.lms_course_id,
    root_organization_id: org[:id].to_s
  end
  factory :document_meta do
    document_id: doc.id,
    key: "enrollment_term_id",
    value: doc.term_id,
    lms_organization_id: "asdasfsgsadf",
    lms_course_id: doc.lms_course_id,
    root_organization_id: org[:id].to_s
  end

end
