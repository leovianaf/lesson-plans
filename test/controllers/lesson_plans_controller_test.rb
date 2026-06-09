require "test_helper"

class LessonPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should get evaluate_next" do
    get root_url
    assert_response :success
  end
end
