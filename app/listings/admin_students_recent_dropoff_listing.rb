class AdminStudentsRecentDropoffListing < Listings::Base
  TRACKS = %w(LH_PRIN TP_PRIN)

  model do
    date_range = School.today.month_range
    date_range = (date_range.begin - 1.month)...date_range.end

    @student_hash = Student
      .joins(student_course_logs: {course_log: {course: :track}})
      .where(course_logs: { date: date_range })
      .where(tracks: {code: TRACKS})
      .group("students.id, tracks.code")
      .pluck("students.id, tracks.code, MAX(course_logs.date), COUNT(*)")
      .inject({}) do |hsh, r|
        hsh[r[0]] ||= {}
        hsh[r[0]][r[1]] ||= {latest: r[2], count: r[3]}
        hsh
      end

    Student.where(id:
      StudentCourseLog.joins(course_log: {course: :track})
      .between(date_range)
      .where(tracks: {code: TRACKS})
      .select("student_id")
    )#.where.not(id:
     # StudentCourseLog.joins(:course_log).where("course_logs.date > ?", School.today - 2.weeks).select(:student_id)
     #)
  end

  column :card_code, searchable: true
  column :first_name, searchable: true
  column :last_name, searchable: true
  column :email, searchable: true do |student|
    if format == :html
      mail_to student.email
    else
      student.email
    end
  end

  TRACKS.each do |track|
    column "u/#{track}" do |student|
      @student_hash[student.id][track][:latest] rescue nil
    end

    column "c/#{track}" do |student|
      @student_hash[student.id][track][:count] rescue nil
    end
  end

  column '' do |student|
    if format == :html
      link_to('ver', admin_student_path(student))
    end
  end

  export :csv, :xls
end
