require 'rails_helper'

RSpec.describe Student, type: :model do
  describe "factory" do
    it "should create" do
      create(:student)
    end
  end

  describe "validates" do
    it "should requires name" do
      expect(build(:student, first_name: nil)).to_not be_valid
    end
  end
end
