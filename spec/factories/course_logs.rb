FactoryGirl.define do
  factory :course_log do
    transient do
      teacher nil
    end
    course
    date { Date.today.next_wday(course.weekday) if course }

    after(:build) do |course_log, evaluator|
      if evaluator.teacher
        course_log.add_teacher(evaluator.teacher.name)
      end
    end
  end
end
