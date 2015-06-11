require 'test_helper'

class Origin::YieldsmanagerControllerTest < ActionController::TestCase
  test "should get groups" do
    get :groups
    assert_response :success
  end

end
