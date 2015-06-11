require 'test_helper'

class Common::UtilControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
