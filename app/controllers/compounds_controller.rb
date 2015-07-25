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
class CompoundsController < ApplicationController
  before_action :set_compound, only: [:show, :edit, :update, :destroy]

  # GET /compounds
  # GET /compounds.json
  def index
    #@compounds = Compound.all[0, 50]
    #@compounds_count = Compound.select("id").count
    @compounds_count = Compound.count
    @compounds = Compound.page params[:page]
    @page = params[:page]
    if @page
      @start = 100*(@page.to_i-1)+1
    else
      @start = 1
    end
    @end = if @compounds_count < @start+100
             @compounds_count
           else
             @start + 100 - 1
           end
  end

  # GET /compounds/1
  # GET /compounds/1.json
  def show
  end

  # GET /compounds/new
  def new
    @compound = Compound.new
  end

  # GET /compounds/1/edit
  def edit
  end

  # POST /compounds
  # POST /compounds.json
  def create
    @compound = Compound.new(compound_params)

    respond_to do |format|
      if @compound.save
        format.html { redirect_to @compound, notice: 'Compound was successfully created.' }
        format.json { render :show, status: :created, location: @compound }
      else
        format.html { render :new }
        format.json { render json: @compound.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compounds/1
  # PATCH/PUT /compounds/1.json
  def update
    respond_to do |format|
      if @compound.update(compound_params)
        format.html { redirect_to @compound, notice: 'Compound was successfully updated.' }
        format.json { render :show, status: :ok, location: @compound }
      else
        format.html { render :edit }
        format.json { render json: @compound.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compounds/1
  # DELETE /compounds/1.json
  def destroy
    @compound.destroy
    respond_to do |format|
      format.html { redirect_to compounds_url, notice: 'Compound was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def filter
    # for histograms

    unless session['score_dist'] and session['frag_score_dist'] and session['iss_dist'] and session['adducts_size_dist'] and session['category_dist'] and session['score_list'] and session['frag_score_list'] and session['iss_list'] and session['adducts_list'] and session['lipid_count'] and session['compound_count'] and session['quant_count']
      score_list = []
      frag_score_list = []
      iss_list = []
      adducts_list = []
      category_list = []
      @unassigned_compounds = 0
      Compound.find_each do |comp|
      #Compound.includes(:lipid).find_each do |comp|
        score_list << comp.score
        frag_score_list << comp.fragmentation_score
        iss_list << comp.isotope_similarity
        adducts_list << comp.adducts_size
      end
      category_list = Compound.includes(:lipid).all.to_a.map{|comp| comp.lipid.category_}

      score_dist = score_list.distribution
      frag_score_dist = frag_score_list.distribution
      iss_dist = iss_list.distribution
      adducts_dist = adducts_list.distribution("integer")
      category_dist = category_list.distribution("category")

      # sort
  #    @score_dist = Hash[*score_dist.sort_by{|key, value| key.first.to_f}.flatten]
  #    @frag_score_dist = Hash[*frag_score_dist.sort_by{|key, value| key.first.to_f}.flatten]
  #    @iss_dist = Hash[*iss_dist.sort_by{|key, value| key.first.to_f}.flatten]
  #    @adducts_size_dist = Hash[*adducts_dist.sort_by{|key, value| key.first.to_f}.flatten]
  #    @category_dist = Hash[*category_dist.sort_by{|key, value| key}.flatten]

      session['score_dist'] = Hash[*score_dist.sort_by{|key, value| key.first.to_f}.flatten]
      session['frag_score_dist'] = Hash[*frag_score_dist.sort_by{|key, value| key.first.to_f}.flatten]
      session['iss_dist'] = Hash[*iss_dist.sort_by{|key, value| key.first.to_f}.flatten]
      session['adducts_size_dist'] = Hash[*adducts_dist.sort_by{|key, value| key.first.to_f}.flatten]
      session['category_dist'] = Hash[*category_dist.sort_by{|key, value| key}.flatten]

      session['score_list'] = [score_list.min, score_list.max, score_list.ave, score_list.sd]
      session['frag_score_list'] = [frag_score_list.min, frag_score_list.max, frag_score_list.ave, frag_score_list.sd]
      session['iss_list'] = [iss_list.min, iss_list.max, iss_list.ave, iss_list.sd]
      session['adducts_list'] = [adducts_list.min, adducts_list.max, adducts_list.ave, adducts_list.sd]
    end
    @score_dist = session['score_dist']
    @frag_score_dist = session['frag_score_dist']
    @iss_dist = session['iss_dist']
    @adducts_size_dist = session['adducts_size_dist']
    @category_dist = session['category_dist']

    @score_list = session['score_list']
    @frag_score_list = session['frag_score_list']
    @iss_list = session['iss_list']
    @adducts_list = session['adducts_list']

  end
  def filter_view
    @minimal_score = params[:minimal_score][:value]
    @minimal_frag_score = params[:minimal_frag_score][:value]
    @minimal_iss = params[:minimal_iss][:value]
    @minimal_n_adducts = params[:minimal_n_adducts][:value]
    @category_name = params[:category][:name]
    @oxidized_filtering = if oxidized_filtering = params[:oxidized_filtering]
                            oxidized_filtering[:flag]
                          else
                            false
                          end

    @compounds_count = Compound.count
    @compounds = Compound.where("score >= ? and fragmentation_score >= ? and isotope_similarity >= ? and adducts_size >= ?", @minimal_score, @minimal_frag_score, @minimal_iss, @minimal_n_adducts)
    if @category_name != 'all'
      @compounds = @compounds.select{|comp| lipid = comp.lipid and lipid.category.name == @category_name}
    end
    if @oxidized_filtering
      @compounds = @compounds.select{|comp| lipid = comp.lipid and lipid.common_name.downcase !~ /oxid(at|iz)ed/}
    end


    @compound2lm_id = {}
    @compound2oxidized = {}
    @compound2category1 = {}
    @compound2category2 = {}
    @compound2category3 = {}
    @compound2quants = {}
    @compounds.each do |comp|
      @compound2quants[comp] ||= []
      #if quant = Quant.find_by_compound(comp.compound)
      if quant = comp.quant
        @compound2quants[comp] << quant
      end
      if lipid = comp.lipid
        @compound2lm_id[comp] = lipid.lm_id
        oxidized = (lipid.common_name.downcase =~ /oxid(at|iz)ed/)
        @compound2oxidized[comp] = ( oxidized ? 'Yes' : 'No')
        @compound2category1[comp] = lipid.category.name
        @compound2category2[comp] = lipid.main_class
        @compound2category3[comp] = lipid.sub_class
      end
    end
    @relative_order_flag = if relative_order = params[:relative_order]
                             relative_order[:flag]
                           else
                             false
                           end
    @relative_order = session[:relative_order]
    if @relative_order_flag and @relative_order
      filtered_compounds = []
      compounds = @compounds
      searched_compounds = {}
      compounds.each do |comp|
        if !searched_compounds[comp.compound] 
          searched_compounds[comp.compound] = true
          if selected_compounds = @compounds.select{|c| c.compound==comp.compound} and selected_compounds.length > 1
            if sort_keys = session[:relative_order]
              selected_compounds.sort_by!{|c| 
                sort_keys.map{|k| c.send(k).to_f} 
              }
              selected_compounds.reverse!
              filtered_compounds << selected_compounds.first
            end
          else
            filtered_compounds << comp
          end
        end
      end
      @compounds = filtered_compounds
    end
  end
  def relative_filter
    @relative_order = session[:relative_order]||[:adducts_size, :fragmentation_score, :score, :isotope_similarity]
  end
  def relative_filter_reset
    session[:relative_order] = [:adducts_size, :fragmentation_score, :score, :isotope_similarity]
    render :text => session[:relative_order]
  end
  def save_relative_filter
    @relative_order = params[:relative_order].sort_by{|key, value| value}.map{|element| element.first.to_sym}
    session[:relative_order] = @relative_order
  end
  def save_as_csv
    @minimal_score = params[:minimal_score][:val]
    @minimal_frag_score = params[:minimal_frag_score][:val]
    @minimal_iss = params[:minimal_iss][:val]
    @minimal_n_adducts = params[:minimal_n_adducts][:val]
    @category_name = params[:category][:name]
    @oxidized_filtering = if oxidized_filtering = params[:oxidized_filtering]
                            oxidized_filtering[:flag]
                          else
                            false
                          end


    compounds = Compound.where("score >= ? and fragmentation_score >= ? and isotope_similarity >= ?", @minimal_score, @minimal_frag_score, @minimal_iss)
    if @category_name != 'all'
      compounds = compounds.select{|comp| lipid = comp.lipid and lipid.category.name == @category_name}
    end
    if @oxidized_filtering
      @compounds = @compounds.select{|comp| lipid = comp.lipid and lipid.common_name.downcase !~ /oxid(at|iz)ed/}
    end

    @compounds = []

    @compound2lm_id = {}
    @compound2oxidized = {}
    @compound2category1 = {}
    @compound2category2 = {}
    @compound2category3 = {}
    @compound2quants = {}
    compounds.each do |comp|
      if comp.adducts.split(/,/).length >= @minimal_n_adducts.to_i
        @compound2quants[comp] ||= []
        if quant = comp.quant
          @compound2quants[comp] << quant
          @compounds << comp
        end
        if lipid = comp.lipid
          #@compounds << comp
          #@compound2quants[comp] ||= []
          #@compound2quants[comp] << Quant.find_by_compound(comp.compound)

          @compound2lm_id[comp] = lipid.lm_id
          oxidized = (lipid.common_name.downcase =~ /oxid(at|iz)ed/)
          @compound2oxidized[comp] = ( oxidized ? 'Yes' : 'No')
          @compound2category1[comp] = lipid.category.name
          @compound2category2[comp] = lipid.main_class
          @compound2category3[comp] = lipid.sub_class
        end
      end
    end
    @relative_order_flag = if relative_order = params[:relative_order_flag]
                             eval(relative_order[:val])
                           else
                             false
                           end
    @relative_order = session[:relative_order]
    if @relative_order_flag and @relative_order
      filtered_compounds = []
      compounds = @compounds
      searched_compounds = {}
      compounds.each do |comp|
        if !searched_compounds[comp.compound] 
          searched_compounds[comp.compound] = true
          if selected_compounds = @compounds.select{|c| c.compound==comp.compound} and selected_compounds.length > 1
            if sort_keys = session[:relative_order]
              selected_compounds.sort_by!{|c| 
                sort_keys.map{|k| c.send(k).to_f} 
              }
              selected_compounds.reverse!
              filtered_compounds << selected_compounds.first
            end
          else
            filtered_compounds << comp
          end
        end
      end
      @compounds = filtered_compounds
    end

    require 'csv'
    quant_headers = []
    @compounds.each do |compound|
       quant_headers.concat(eval(@compound2quants[compound].first.samples).keys)
    end
    quant_headers.uniq!
    quant_headers.sort!
    quant_raw_headers = quant_headers.map{|header| "#{header}_Raw"}
    quant_norm_headers = quant_headers.map{|header| "#{header}_Norm"}
    headers = [
      "Compound",
      "Compound ID (SID)",
      "LM_ID",
      "Oxidized",
      "Adducts",
      "Score",
      "Fragmentation score",
      "Mass error",
      "Isotope similarity",
      "Category1",
      "Category2",
      "Category3",
      "Retention time",
      "Link",
      "Description",
    ].concat(quant_raw_headers).concat(quant_norm_headers)
    csv_string = CSV.generate do |out|
      out << headers
      @compounds.each do |compound|
        quants = eval(@compound2quants[compound].first.samples)
        quant_raws = quant_headers.map{|header| quants[header].first}
        quant_norms = quant_headers.map{|header| quants[header].last}
        out << [
          compound.compound,
          compound.compound_id,
          @compound2lm_id[compound].to_s,
          @compound2oxidized[compound].to_s,
          compound.adducts,
          compound.score,
          compound.fragmentation_score,
          compound.mass_error,
          compound.isotope_similarity,
          compound.retention_time,
          @compound2category1[compound].to_s,
          @compound2category2[compound].to_s,
          @compound2category3[compound].to_s,
          compound.link,
          compound.description,
        ].concat(quant_raws).concat(quant_norms)
      end
    end
    send_data csv_string,
     :type => 'text/csv',
     :disposition => "attachment; filename=filtered_coumpound_IDs.csv"
  end
  def search_compounds
    @compounds = if compound_id = params[:format]
                   Compound.where("compound_id = ?", compound_id)
                 else
                   []
                 end
  end
  def delete_all
    Compound.delete_all
    session['compound_count'] = nil
    @comment = "delete all compounds"
    #render :text => 'delete_all'
  end

  def feature
    @compound = params[:feature]
    @idents = Compound.where(compound: @compound)

    quant = Quant.where(compound: @compound).take
    @quants = nil

    if not quant.nil?
      @quants = eval(quant.samples)
      @raw_min = nil
      @raw_max = nil
      @norm_min = nil
      @norm_max = nil
      @quants.each do |key, values|
        values[0] = values[0].to_i
        values[1] = values[1].to_i
        @raw_min = values[0] if @raw_min.nil? or values[0]<@raw_min
        @raw_max = values[0] if @raw_max.nil? or values[0]>@raw_max
        @norm_min = values[1] if @norm_min.nil? or values[1]<@norm_min
        @norm_max = values[1] if @norm_max.nil? or values[1]>@norm_max
      end
      @norm_max = @norm_max-@norm_min
      @raw_max = @raw_max-@raw_min
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compound
      @compound = Compound.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def compound_params
      params.require(:compound).permit(:compound, :compound_id, :adducts, :score, :fragmentation_score, :mass_error, :isotope_similarity, :retention_time, :link, :description)
    end
end
