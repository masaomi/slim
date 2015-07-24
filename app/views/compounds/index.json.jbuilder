json.array!(@compounds) do |compound|
  json.extract! compound, :id, :compound, :compound_id, :adducts, :score, :fragmentation_score, :mass_error, :isotope_similarity, :retention_time, :link, :description
  json.url compound_url(compound, format: :json)
end
