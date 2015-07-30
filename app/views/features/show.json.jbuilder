json.(@feature, :rt, :m_z, :mass, :charge, :id_string)
json.url feature_path(@feature)

json.identifications do
  json.array!(@feature.identifications) do |id|
    json.extract! id, :score, :fragmentation_score, :isotope_similarity, :mass_error, :adducts
    json.extract! id.lipid, :id, :common_name, :oxidations, :lm_id
    json.url lipid_path(id.lipid)
  end
end
json.samples do
  json.array!(Sample.to_hash.values)
end
json.quantifications do
  json.array!(@feature.quants.values.map {|v| v[1]}) #only return normalized values
end
