require 'test_helper'

class FilterControllerTest < ActionController::TestCase
  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get csv" do
    get :csv
    assert_response :success
  end

end
