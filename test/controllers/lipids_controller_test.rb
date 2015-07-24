require 'test_helper'

class LipidsControllerTest < ActionController::TestCase
  setup do
    @lipid = lipids(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lipids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lipid" do
    assert_difference('Lipid.count') do
      post :create, lipid: { category: @lipid.category, chebi_id: @lipid.chebi_id, common_name: @lipid.common_name, exact_mass: @lipid.exact_mass, formula: @lipid.formula, inchi_key: @lipid.inchi_key, kegg_id: @lipid.kegg_id, lipid_maps_cmpd_url: @lipid.lipid_maps_cmpd_url, lm_id: @lipid.lm_id, main_class: @lipid.main_class, pubchem_cid: @lipid.pubchem_cid, pubchem_sid: @lipid.pubchem_sid, pubchem_substane_url: @lipid.pubchem_substane_url, status: @lipid.status, sub_class: @lipid.sub_class, synonyms: @lipid.synonyms, systematic_name: @lipid.systematic_name }
    end

    assert_redirected_to lipid_path(assigns(:lipid))
  end

  test "should show lipid" do
    get :show, id: @lipid
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lipid
    assert_response :success
  end

  test "should update lipid" do
    patch :update, id: @lipid, lipid: { category: @lipid.category, chebi_id: @lipid.chebi_id, common_name: @lipid.common_name, exact_mass: @lipid.exact_mass, formula: @lipid.formula, inchi_key: @lipid.inchi_key, kegg_id: @lipid.kegg_id, lipid_maps_cmpd_url: @lipid.lipid_maps_cmpd_url, lm_id: @lipid.lm_id, main_class: @lipid.main_class, pubchem_cid: @lipid.pubchem_cid, pubchem_sid: @lipid.pubchem_sid, pubchem_substane_url: @lipid.pubchem_substane_url, status: @lipid.status, sub_class: @lipid.sub_class, synonyms: @lipid.synonyms, systematic_name: @lipid.systematic_name }
    assert_redirected_to lipid_path(assigns(:lipid))
  end

  test "should destroy lipid" do
    assert_difference('Lipid.count', -1) do
      delete :destroy, id: @lipid
    end

    assert_redirected_to lipids_path
  end
end
