module FeaturesHelper
  class FilteringCriteria
    attr_accessor :minimal, :relative, :oxichain
    def initialize(session)
      @minimal = {
        'score' => 20,
        'fragmentation_score' => 1,
        'isotope_similarity' => 90,
        'mass_error' => 0.6,
        'adducts' => 1
      }
      @relative = ['fragmentation_score','score','isotope_similarity','mass_error','adducts']
      @oxichain = nil
      @minimal = session[:filtering_minimal] if not session[:filtering_minimal].nil?
      @relative = session[:filtering_relative] if not session[:filtering_relative].nil?
      if not session[:filtering_oxichain].nil?
        @oxichain = session[:filtering_oxichain] ? nil : false
      end
    end
    def oxichain?
      @oxichain != false
    end
    def oxichain! newvalue
      if newvalue
        @oxichain = nil
      else
        @oxichain = false
      end
    end
    def save(session)
      session[:filtering_minimal] = @minimal
      session[:filtering_relative] = @relative
      session[:filtering_oxichain] = @oxichain == false ? false : true
    end
  end


  def filteredCompounds(crit)
    # step 1: absolute filtering
    features = {}
    Compound.where("score >= ? and fragmentation_score >= ? and isotope_similarity >= ? and adducts_size >= ?",
                   crit.minimal['score'],crit.minimal['fragmentation_score'], crit.minimal['isotope_similarity'],
                   crit.minimal['adducts']).each do |feature|
      features[feature.compound] ||= []
      features[feature.compound] << feature
    end

    # step 2: relative filtering
    library = []
    output = []
    features.each do |key, compounds|
      #presort using compound_id to guarantee a reproducible result
      compounds.sort! {|a,b| if a.compound_id > b.compound_id
                               1  #b follows a
                             elsif b.compound_id > a.compound_id
                               -1 #a follows b
                             else
                               0 # a and b are equivalent
                             end}
      crit.relative.reverse_each do |criterium|
        case criterium
          when 'score'
            compounds.sort! {|a,b| if a.score > b.score
                                     1  #b follows a
                                   elsif b.score > a.score
                                     -1 #a follows b
                                   else
                                     0 # a and b are equivalent
                                   end
            }
          when 'fragmentation_score'
            compounds.sort! {|a,b| if a.fragmentation_score > b.fragmentation_score
                                     1  #b follows a
                                   elsif b.fragmentation_score > a.fragmentation_score
                                     -1 #a follows b
                                   else
                                     0 # a and b are equivalent
                                   end
            }
          when 'isotope_similarity'
            compounds.sort! {|a,b| if a.isotope_similarity > b.isotope_similarity
                                     1  #b follows a
                                   elsif b.isotope_similarity > a.isotope_similarity
                                     -1 #a follows b
                                   else
                                     0 # a and b are equivalent
                                   end
            }
          when 'mass_error'
            compounds.sort! {|a,b| if a.mass_error > b.mass_error
                                     1  #b follows a
                                   elsif b.mass_error > a.mass_error
                                     -1 #a follows b
                                   else
                                     0 # a and b are equivalent
                                   end
            }
          when 'adducts'
            compounds.sort! {|a,b| if a.adducts_size > b.adducts_size
                                     1  #b follows a
                                   elsif b.adducts_size > a.adducts_size
                                     -1 #a follows b
                                   else
                                     0 # a and b are equivalent
                                   end
            }
          else
            raise StandardError, 'Tried to sort by parameter %s, but this parameter does not exist.'%criterium
        end
      end

      #fourth step: oxichaining
      if not crit.oxichain.nil? and crit.oxichain.count
        compounds.sort! {|a,b| if crit.oxichain.include? a.lipid.parent
                                 if crit.oxichain.include? b.lipid.parent
                                   0
                                 else
                                   1
                                 end
                               else
                                 if crit.oxichain.include? b.lipid.parent
                                   -1
                                 else
                                   0
                                 end
                               end}
      end

      output << compounds.first
      if crit.oxichain.nil?
        # third step: generate oxichaining library
        library << compounds.first.lipid.parent
      end
    end
    if crit.oxichain.nil?
      crit.oxichain = library.uniq!
      return filteredCompounds(crit)
    else
      return output
    end
  end
end
