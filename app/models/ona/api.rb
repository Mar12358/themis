require 'rest_client'

module Ona
  class Api
    def initialize(api_token)
      @api_token = api_token
      @options = {:Authorization => "Token #{api_token}"}
    end

    def get_json(url)
      JSON.parse(RestClient.get("http://ona.io/api/v1/#{url}", @options))
    end

    def user
      @user ||= get_json("user.json")
    end

    def forms
      @forms ||= get_json("data.json")
    end

    def form_by_id_string(id_string)
      forms.find { |f| f["id_string"] == id_string }
    end

    def submission_edit_url(data)
      "https://ona.io/webform?project-id=#{Settings.ona_project_id}&instance-id=#{data["_id"]}&dataset-id=#{Settings.ona_dataset_id}"
    end

    def submission_updated_data(data)
      get_json("data/#{form_by_id_string(data["_xform_id_string"])["id"]}/#{data["_id"]}.json")
    end
  end
end
