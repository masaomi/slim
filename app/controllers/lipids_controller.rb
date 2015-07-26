class LipidsController < ApplicationController
  before_action :set_lipid, only: [:show, :edit, :update, :destroy]

  # GET /lipids
  # GET /lipids.json
  def index
    #@page_size = 50
    #@pages = Lipid.all.length / @page_size
    #@lipids = Lipid.all[0, @page_size]
    #@lipids_count = Lipid.select("id").count
    @lipids_count = Lipid.count
    @lipids = Lipid.page params[:page]
    @page = params[:page]
    if @page
      @start = 100*(@page.to_i-1)+1
    else
      @start = 1
    end
    @end = if @lipids_count < @start+100
             @lipids_count
           else
             @start + 100
           end
  end

  # GET /lipids/1
  # GET /lipids/1.json
  def show
    if @lipid.parent != @lipid.lm_id
      @parent = Lipid.where(lm_id: @lipid.parent).take
    end
  end

  # GET /lipids/new
  def new
    @lipid = Lipid.new
  end

  # GET /lipids/1/edit
  def edit
  end

  # POST /lipids
  # POST /lipids.json
  def create
    @lipid = Lipid.new(lipid_params)

    respond_to do |format|
      if @lipid.save
        format.html { redirect_to @lipid, notice: 'Lipid was successfully created.' }
        format.json { render :show, status: :created, location: @lipid }
      else
        format.html { render :new }
        format.json { render json: @lipid.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lipids/1
  # PATCH/PUT /lipids/1.json
  def update
    respond_to do |format|
      if @lipid.update(lipid_params)
        format.html { redirect_to @lipid, notice: 'Lipid was successfully updated.' }
        format.json { render :show, status: :ok, location: @lipid }
      else
        format.html { render :edit }
        format.json { render json: @lipid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lipids/1
  # DELETE /lipids/1.json
  def destroy
    @lipid.destroy
    respond_to do |format|
      format.html { redirect_to lipids_url, notice: 'Lipid was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_all
    Lipid.delete_all
    Category.delete_all
    session['lipid_count'] = nil
    @comment = "delete all lipids and categories"
    #render :text => 'delete_all'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lipid
      @lipid = Lipid.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lipid_params
      params.require(:lipid).permit(:lm_id, :pubchem_substane_url, :lipid_maps_cmpd_url, :common_name, :systematic_name, :synonyms, :category, :main_class, :sub_class, :exact_mass, :formula, :pubchem_sid, :pubchem_cid, :kegg_id, :chebi_id, :inchi_key, :status)
    end
end
