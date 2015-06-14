class TeacherCourseLogStudentsListing < Listings::Base
  model do
    @course_log = CourseLog.find(params[:id])
    @course_log.students
  end

  def find_student_log(student)
    @course_log.student_course_logs.where(student: student).first
  end

  column 'id_kind' do |student|
    student_log = find_student_log(student)
    student_log.id_kind
  end

  column :card_code, searchable: true
  column :first_name, searchable: true
  column :last_name, searchable: true
  column 'Pago' do |student|
    payment_amount = find_student_log(student).incomes.sum(:payment_amount)
    if payment_amount > 0
      number_to_currency payment_amount
    end
  end

  column 'Tipo' do |student|
    student_log = find_student_log(student)
    student_log.payment_plan.try :code
  end

  column '' do |student|
    student_log = find_student_log(student)
    text_modal('...', 'Payload', JSON.pretty_generate(JSON.parse(student_log.payload)))
  end

  export :csv, :xls

end
