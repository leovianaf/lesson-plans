require "test_helper"

class LessonPlansControllerTest < ActionDispatch::IntegrationTest
  test "should get evaluate_next" do
    get lesson_plans_evaluate_next_url
    assert_response :success
  end
end
