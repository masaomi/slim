require 'test_helper'

class ImportControllerTest < ActionController::TestCase
  test "should get experiment" do
    get :experiment
    assert_response :success
  end

end
