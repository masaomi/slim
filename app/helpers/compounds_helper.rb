module CompoundsHelper
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


#mods of Array and Hash for statistics
class Array
  def sum
    inject(0.0){|s,i| s+i}
  end
  def sum2
    inject(0.0){|s,i| s+i*i}
  end
  def ave
    @ave ||= sum/length
  end
  def ave2
    @ave2 ||= sum2/length
  end
  def var
    ave2 - ave**2
  end
  def sd
    Math.sqrt(var)
  end

  def interval
    #@interval ||= 6*sd / 9
    @interval ||= (dist_max-dist_min)/10
    if @interval.abs < 1e-10
      @interval = 1
    end
    @interval
  end
  def dist_min
    @dist_min ||= [ave-2*sd, min].max
  end
  def dist_max
    @dist_max ||= [ave+2*sd, max].min
  end
end
class Hash
  def set_range(data_list, type=nil)
    if type == 'integer'
      data_list.min.step(data_list.max, 1) do |bottom|
        range = bottom..bottom
        self[range] ||= 0
      end
    elsif type == 'category'
      data_list.uniq.each do |label|
        self[label] ||= 0
      end
    else
      data_list.dist_min.step(data_list.dist_max, data_list.interval) do |bottom|
        range = bottom..(bottom+data_list.interval)
        self[range] ||= 0
      end
    end
  end
  def dist_count(data_list, type=nil)
    if type == 'category'
      data_list.each do |value|
        self[value] += 1
      end
    else
      data_list.each do |value|
        keys.each do |range|
          if range.cover?(value)
            self[range] += 1
            break
          end
        end
      end
    end
  end
  def value_total
    @value_total ||= values.sum
  end
  def format(value)
    @format ||= if value.is_a?(Integer)
                  "%d"
                  #elsif Math.log10(value.abs).to_i >= 0
                  #  "%.1f"
                elsif value.is_a?(Float)
                  "%.1f"
                else
                  "%s"
                end
  end
  def percentile(type=nil)
    if type == 'integer'
      map{|range, value|
        #["#{format(range.first)}" % range.first, value.to_f/value_total]
        ["#{format(range.first)}" % range.first, value]
      }
    elsif type == 'category'
      map{|label, value|
        ["#{format(label)}" % label, value]
      }
    else
      map{|range, value|
        ["#{format(range.first)} - #{format(range.last)}" % [range.first, range.last], value]
      }
    end
  end
  def distribution(data_list, type=nil)
    set_range(data_list, type)
    dist_count(data_list, type)
    percentile(type)
  end

end
class Array
  def distribution(type=nil)
    dist = {}
    dist.distribution(self, type)
  end
end
