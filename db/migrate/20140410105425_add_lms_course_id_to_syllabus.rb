class AddLmsCourseIdToSyllabus < ActiveRecord::Migration
  def change
    add_column :syllabuses, :lms_course_id, :string
    add_column :syllabuses, :lms_published_at, :datetime
    add_index :syllabuses, :lms_course_id
  end
end
