json.array!(@quants) do |quant|
  json.extract! quant, :id, :compound, :samples
  json.url quant_url(quant, format: :json)
end
