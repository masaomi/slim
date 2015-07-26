include CompoundsHelper
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


  end
  def filter_view

  end
  def save_as_csv
    criteria = FilteringCriteria.new(session)
    results = filteredCompounds(criteria)
    headers = results.first
    headers = eval(headers.quant.samples).keys if headers.quant.samples
    headers = [] if headers.nil?
    require 'csv'
    # step 1: write headers
    feature_description =  [
      'feature',
      'retention_time',
      'mass',
      'lipid',
      'parent_lipid',
      'common_name',
      'oxidations',
      'score',
      'fragmentation_score',
      'mass_error',
      'isotope_similarity',
      'category',
      'cat1',
      'cat2',
      'cat3',
      'n_identifications'
    ]
    csv_headers = Array.new(feature_description)
    csv_headers.concat(headers.map{|header| "#{header}_raw"}).concat(headers.map{|header| "#{header}_norm"})
    csv_string = CSV.generate do |out|
      out << csv_headers
      results.each do |feature|
        result = []
        feature_description.each do |header|
          case header
            when 'feature'
              result << feature.compound
              if feature.compound =~ /(\d+.\d+)_(\d+.\d+[nm\/z]+)/
                result << $1
                result << $2
              else
                result << ""
                result << ""
              end
            when 'retention_time','mass'
              #don't do anything, we have already added these parameters in feature
            when 'lipid'
              result << feature.lipid.lm_id
            when 'parent_lipid'
              result << feature.lipid.parent
            when 'common_name'
              result << feature.lipid.common_name
            when 'oxidations'
              result << "%0i"%feature.lipid.oxidations
            when 'score'
              result << "%.4f"%feature.score
            when 'fragmentation_score'
              result << "%.4f"%feature.fragmentation_score
            when 'mass_error'
              result << "%.6f"%feature.mass_error
            when 'isotope_similarity'
              result << "%.6f"%feature.isotope_similarity
            when 'category'
              result << feature.lipid.sub_class
              if feature.lipid.sub_class =~/\[(\w\w)(\d\d)(\d\d)\]/
                result << $1
                result << $1+$2
                result << $1+$2+$3
              else
                result << ""
                result << ""
                result << feature.lipid.sub_class
              end
            when 'cat1','cat2','cat3'
              #don't do anything
            when 'n_identifications'
              result << Compound.where(compound: feature.compound).count
            else
              raise StandardError, 'cannot extract property %s from feature'%header
          end
        end
        quants = eval(feature.quant.samples)
        if quants.nil?
          result.concat(Array.new(headers.length*2,""))
        else
          quants.each do |key, quant|
            result << "%.2f"%quant[0]
          end
          quants.each do |key, quant|
            result << "%.2f"%quant[1]
          end
        end
        out << result
      end
    end
    criteria.save(session)
    send_data csv_string,
     :type => 'text/csv',
     :disposition => "attachment; filename=%s_results.csv"%Time.now.to_formatted_s(:number)
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
