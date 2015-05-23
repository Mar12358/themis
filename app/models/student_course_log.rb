class StudentCourseLog < ActiveRecord::Base
  PAYMENT_ON_TEACHER = 'teacher'

  belongs_to :student
  belongs_to :course_log
  belongs_to :teacher
  serialize :payload, JSON

  validates_presence_of :student, :course_log
  validate :validate_teacher_in_course_log

  scope :owed, -> { where(payment_status: PAYMENT_ON_TEACHER) }

  def validate_teacher_in_course_log
    return unless teacher && course_log

    errors.add(:teacher, 'must be in the course_log') unless course_log.teachers.include?(teacher)
  end

  def self.process(course_log, teacher, payload)
    id_kind = payload["student_repeat/id_kind"]
    card = payload["student_repeat/card"]
    email = payload["student_repeat/email"]
    name = payload["student_repeat/name"]
    do_payment = payload["student_repeat/do_payment"]
    payment_kind = payload["student_repeat/payment/kind"]
    payment_amount = payload["student_repeat/payment/amount"]

    # skip empty students
    return if card.blank? and email.blank? and name.blank? and payment_kind.blank?

    case id_kind
    when "new_card"
      student = Student.find_or_initialize_by card_code: card
      if student.new_record? || student.first_name == Student::UNKOWN || student.email == nil
        student.first_name = name
        student.email = email
        student.save!
      end
    when "existing_card"
      student = Student.find_or_initialize_by card_code: card
      if student.new_record?
        student.first_name = Student::UNKOWN
        student.email = nil
        student.save!
      end
    when "guest"
      if email.blank?
        student = Student.new email: nil
      else
        student = Student.find_or_initialize_by email: email
      end

      if student.new_record?
        student.card_code = nil
        student.first_name = name || Student::UNKOWN
        student.save!
      end
    else
      raise 'not supported id_kind'
    end

    # TODO better error when student is nil
    student_log = course_log.student_course_logs.first_or_build(student: student)
    student_log.payload = payload.to_json
    student_log.teacher = teacher


    if do_payment == "yes"
      case payment_kind
      when PaymentPlan::OTHER
        student_log.payment_amount = payment_amount
        student_log.payment_status = StudentCourseLog::PAYMENT_ON_TEACHER
      else
        student_log.payment_amount = PaymentPlan.find_by!(code: payment_kind).price
        student_log.payment_status = StudentCourseLog::PAYMENT_ON_TEACHER
      end
    else
      student_log.payment_status = nil
    end

    student_log.save!
  end
end
