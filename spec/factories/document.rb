FactoryBot.define do
  #document factory
  factory :document do
    organization_id 1
    name "Document"
    lms_course_id "32342"
    lms_published_at DateTime.now
    created_at DateTime.now.ago(10)
    updated_at DateTime.now
    after :create do |doc|
      create :dm_account_id, document_id: doc.id, root_organization_id: doc.organization_id, lms_course_id: doc.lms_course_id
      create :dm_name, document_id: doc.id, root_organization_id: doc.organization_id, lms_course_id: doc.lms_course_id
      create :dm_total_students, document_id: doc.id, root_organization_id: doc.organization_id, lms_course_id: doc.lms_course_id
      create :dm_enrollment_term_id, document_id: doc.id, root_organization_id: doc.organization_id, lms_course_id: doc.lms_course_id
    end
  end
  # document meta factory
  factory :dm_account_id, class: DocumentMeta do
    key "account_id"
    value "CLS"
    lms_organization_id "asdasfsgsadf"
    lms_course_id 324455
    root_organization_id 1
    association :document, factory: :document
  end
  factory :dm_name, class: DocumentMeta do
    key "name"
    value "FL17"
    lms_organization_id "asdasfsgsadf"
    lms_course_id 324455
    root_organization_id 1
    association :document, factory: :document
  end
  factory :dm_total_students, class: DocumentMeta do
    key "total_students"
    value "43"
    lms_organization_id "asdasfsgsadf"
    lms_course_id 324455
    root_organization_id 1
    association :document, factory: :document
  end
  factory :dm_enrollment_term_id, class: DocumentMeta do
    key "enrollment_term_id"
    value "34"
    lms_organization_id "asdasfsgsadf"
    lms_course_id 324455
    root_organization_id 1
    association :document, factory: :document
  end
end
