require 'test_helper'

class Origin::InventorymanagerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
