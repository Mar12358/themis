class AddOnaSubmissionAndOnaSubmissionPathToStudentCourseLog < ActiveRecord::Migration
  def change
    add_reference :student_course_logs, :ona_submission, index: true, foreign_key: true
    add_column :student_course_logs, :ona_submission_path, :string
  end
end
