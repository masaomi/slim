json.array!(@lipids) do |lipid|
  json.extract! lipid, :id, :lm_id, :pubchem_substane_url, :lipid_maps_cmpd_url, :common_name, :category, :sub_class
  json.url lipid_url(lipid, format: :json)
end
