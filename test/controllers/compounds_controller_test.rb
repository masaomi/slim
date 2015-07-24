require 'test_helper'

class CompoundsControllerTest < ActionController::TestCase
  setup do
    @compound = compounds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compounds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compound" do
    assert_difference('Compound.count') do
      post :create, compound: { adducts: @compound.adducts, compound: @compound.compound, compound_id: @compound.compound_id, description: @compound.description, fragmentation_score: @compound.fragmentation_score, isotope_similarity: @compound.isotope_similarity, link: @compound.link, mass_error: @compound.mass_error, retention_time: @compound.retention_time, score: @compound.score }
    end

    assert_redirected_to compound_path(assigns(:compound))
  end

  test "should show compound" do
    get :show, id: @compound
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @compound
    assert_response :success
  end

  test "should update compound" do
    patch :update, id: @compound, compound: { adducts: @compound.adducts, compound: @compound.compound, compound_id: @compound.compound_id, description: @compound.description, fragmentation_score: @compound.fragmentation_score, isotope_similarity: @compound.isotope_similarity, link: @compound.link, mass_error: @compound.mass_error, retention_time: @compound.retention_time, score: @compound.score }
    assert_redirected_to compound_path(assigns(:compound))
  end

  test "should destroy compound" do
    assert_difference('Compound.count', -1) do
      delete :destroy, id: @compound
    end

    assert_redirected_to compounds_path
  end
end
