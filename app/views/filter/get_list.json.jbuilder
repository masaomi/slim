json.array!(@results) do |identification|
  json.id identification.id
  json.lipid do
    json.extract! identification.lipid, :id, :common_name, :category_, :main_class, :sub_class, :oxidations
  end
  json.feature do
    json.extract! identification.feature, :id, :id_string, :m_z, :rt
  end
  json.n_ids Identification.where(feature: identification.feature).count
  json.values do
    a = []
    identification.feature.quants.each do |id, value|
      a << value
    end
    json.array! a.flatten
  end
  json.lipid_url do
    json.url lipid_url identification.lipid
  end
  json.feature_url do
    json.url feature_url identification.feature
  end
end