require 'test_helper'

class QuantsControllerTest < ActionController::TestCase
  setup do
    @quant = quants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quant" do
    assert_difference('Quant.count') do
      post :create, quant: { compound: @quant.compound, samples: @quant.samples }
    end

    assert_redirected_to quant_path(assigns(:quant))
  end

  test "should show quant" do
    get :show, id: @quant
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quant
    assert_response :success
  end

  test "should update quant" do
    patch :update, id: @quant, quant: { compound: @quant.compound, samples: @quant.samples }
    assert_redirected_to quant_path(assigns(:quant))
  end

  test "should destroy quant" do
    assert_difference('Quant.count', -1) do
      delete :destroy, id: @quant
    end

    assert_redirected_to quants_path
  end
end
