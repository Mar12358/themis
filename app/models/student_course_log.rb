class StudentCourseLog < ActiveRecord::Base
  PAYMENT_ON_TEACHER = 'teacher'
  PAYMENT_ON_CLASSES_INCOME = 'classes_income'

  belongs_to :student
  belongs_to :course_log
  belongs_to :teacher
  serialize :payload, JSON
  belongs_to :payment_plan
  belongs_to :ona_submission
  before_save :payments_initially_on_teachers
  after_save :record_student_activities

  validates_presence_of :student, :course_log
  validate :validate_teacher_in_course_log
  validate :validate_teacher_if_paying

  scope :with_payment, -> { where.not(payment_status: nil) }
  scope :owed, -> { where(payment_status: PAYMENT_ON_TEACHER) }
  scope :handed, -> { where(payment_status: PAYMENT_ON_CLASSES_INCOME) }

  def validate_teacher_in_course_log
    return unless teacher && course_log

    errors.add(:teacher, 'must be in the course_log') unless course_log.teachers.include?(teacher)
  end

  def validate_teacher_if_paying
    return unless payment_plan

    errors.add(:teacher, "can't be blank") unless teacher
  end

  def self.process(course_log, teacher, payload, ona_submission, ona_submission_path)
    id_kind = payload["student_repeat/id_kind"]
    card = payload["student_repeat/cardtxt"]
    card = payload["student_repeat/card"] if card.blank?
    email = payload["student_repeat/email"]
    first_name = payload["student_repeat/first_name"]
    last_name = payload["student_repeat/last_name"]
    do_payment = payload["student_repeat/do_payment"]
    payment_kind = payload["student_repeat/payment/kind"]
    payment_amount = payload["student_repeat/payment/amount"]

    # skip empty students
    return if card.blank? and email.blank? and first_name.blank? and payment_kind.blank?

    # if there already was a student course log for this part of the submission
    student = nil
    existing_log = StudentCourseLog.where(ona_submission: ona_submission, ona_submission_path: ona_submission_path).first
    if existing_log
      student = existing_log.student
    end

    case id_kind
    when "new_card"
      student ||= Student.find_or_initialize_by_card card
      if student.new_record? || student.first_name == Student::UNKOWN || student.email == nil
        student.first_name = first_name
        student.last_name = last_name
        student.email = email
        student.save!
      end
    when "existing_card"
      student ||= Student.find_or_initialize_by_card card
      if student.new_record?
        student.first_name = Student::UNKOWN
        student.last_name = Student::UNKOWN
        student.email = nil
        student.save!
      end
    when "guest"
      if email.blank?
        student ||= Student.new email: nil
      else
        student ||= Student.find_or_initialize_by email: email
      end

      if student.new_record?
        student.card_code = nil
        student.first_name = first_name || Student::UNKOWN
        student.last_name = last_name || Student::UNKOWN
        student.save!
      end
    else
      raise 'not supported id_kind'
    end

    # TODO better error when student is nil
    student_log = existing_log || course_log.student_course_logs.first_or_build(student: student)
    student_log.payload = payload.to_json
    student_log.teacher = teacher
    if student_log.new_record?
      student_log.ona_submission = ona_submission
      student_log.ona_submission_path = ona_submission_path
    end

    if do_payment == "yes"
      # TODO error handling
      plan = PaymentPlan.find_by!(code: payment_kind)
      student_log.payment_plan = plan
      student_log.payment_amount = payment_amount if plan.other?
    else
      student_log.payment_plan = nil
    end

    student_log.save!
  end

  def payments_initially_on_teachers
    plan = self.payment_plan


    if plan
      self.payment_status ||= StudentCourseLog::PAYMENT_ON_TEACHER
      self.payment_amount = plan.price unless plan.other?

      # TODO when the amount is updated. revert previous payment line.
      # TODO when updating, if amount didn't change, do not create payment
    else
      self.payment_status ||= nil
    end

    true
  end

  def record_student_activities
    ActivityLogs::Student::CourseAttended.record(student, course_log)
    if payment_plan
      ActivityLogs::Student::Payment.record(student, self)
    end
  end

end