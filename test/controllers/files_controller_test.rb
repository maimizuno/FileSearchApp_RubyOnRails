require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get files_new_url
    assert_response :success
  end
end
