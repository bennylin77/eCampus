require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  test "should get info" do
    get :info
    assert_response :success
  end

  test "should get quiz" do
    get :quiz
    assert_response :success
  end

end
