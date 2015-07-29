module FeaturesHelper
  def search_oxidated(feature)
    min_mass, max_mass = feature.m_z + 15.994915 - 0.0006417872, feature.m_z + 15.994915 + 0.0006417872
    expected_mass = feature.m_z + 15.994915
    #min_rt, max_rt = feature.rt - 5, feature.rt - 0.01
    min_rt, max_rt = feature.rt*(0.44+0.07*Math.log(feature.m_z)), feature.rt*(0.72+0.04*Math.log(feature.m_z))
    best_result = nil
    Feature.where('m_z BETWEEN ? AND ?',min_mass,max_mass).where('rt BETWEEN ? AND ?',min_rt, max_rt).where("oxichain IS NULL OR oxichain = ?",false).find_each do |oxi|
      if best_result.nil?
        best_result = oxi
        next
      end
      best_result = oxi if (oxi.m_z-expected_mass).abs < (best_result.m_z-expected_mass).abs
    end
    return best_result
  end
end
