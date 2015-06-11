require 'test_helper'

class Origin::YieldsmanageControllerTest < ActionController::TestCase
  test "should get purchasingYield" do
    get :purchasingYield
    assert_response :success
  end

end
