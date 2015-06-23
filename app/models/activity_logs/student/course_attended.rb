class ActivityLogs::Student::CourseAttended < ActivityLog
  def self.record(student, course_log)
    create(target: student, related: course_log,
      date: course_log.date,
      description: "Asistió a #{course_log.calendar_name}.")
  end

  def self.for(student, course_log)
    where(target: student, related: course_log, date: course_log.date)
  end
end
