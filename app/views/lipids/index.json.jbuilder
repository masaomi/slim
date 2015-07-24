json.array!(@lipids) do |lipid|
  json.extract! lipid, :id, :lm_id, :pubchem_substane_url, :lipid_maps_cmpd_url, :common_name, :systematic_name, :synonyms, :category, :main_class, :sub_class, :exact_mass, :formula, :pubchem_sid, :pubchem_cid, :kegg_id, :chebi_id, :inchi_key, :status
  json.url lipid_url(lipid, format: :json)
end
