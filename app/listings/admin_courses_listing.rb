class AdminCoursesListing < Listings::Base
  include ApplicationHelper

  model { Course.order(:weekday, :start_time, :code) }

  scope 'Vigentes', :ongoing_or_future, default: true
  scope 'Todos', :all

  column :code
  column "Descripción" do |c|
    c.description(:track, :place)
  end
  column :weekday do |c|
    local_wday(c.weekday)
  end
  column :start_time do |c|
    if c.start_time
      "#{c.start_time.hour}:#{"%02d" % c.start_time.min}"
    end
  end
  column :place do |c|
    name = c.place.try &:name
    name = nil if name == School.description
    name
  end
  column :valid_since
  column :valid_until

  export :xls, :csv

end
