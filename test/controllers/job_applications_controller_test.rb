require 'test_helper'

class JobApplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get job_applications_create_url
    assert_response :success
  end

end
