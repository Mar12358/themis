require 'rails_helper'

RSpec.describe Admin::CoursesController, type: :controller do
  include AdminControllerHelper

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
