require 'rails_helper'

describe "room page" do
  include_context "swc context"

  it "can be accessed from home page using code" do
    goto_page Home do |page|
      page.room_link.click
    end

    expect_page RoomLogin do |page|
      page.password.set Settings.room_password
      page.submit.click
    end

    expect_page RoomCoursePicker do |page|
      expect(page.text).to match /Apertura de clase/i
    end
  end

  it "shows todays course" do
    signin_as_room

    expect_page RoomCoursePicker do |page|
      expect(page.text).to match lh_int1_description
      expect(page.text).to_not match lh_int2_description

      page.select_course lh_int1_description
    end
  end

  it "creates course_log with selected teacher" do
    expect(CourseLog.count).to eq 0

    signin_as_room

    expect_page RoomCoursePicker do |page|
      page.select_course lh_int1_description
    end

    expect_page RoomTeacherPicker do |page|
      page.select_teacher mariel.name
      page.submit.click
    end

    expect(CourseLog.count).to eq 1
    course_log = CourseLog.first
    expect(course_log.teachers).to eq [mariel]
    expect(course_log.course).to eq lh_int1_today
    expect(course_log.students).to be_empty
  end
end