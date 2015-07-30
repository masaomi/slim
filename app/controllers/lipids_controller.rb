class LipidsController < ApplicationController
  before_action :set_lipid, only: [:show]

  # GET /lipids
  # GET /lipids.json
  def index
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

  def search
    @lipids = Lipid.where('common_name LIKE ?','%%%s%%'%params[:search].downcase)
    @lipids_count = @lipids.count
    @search = params[:search]
  end

  # GET /lipids/1
  # GET /lipids/1.json
  def show
    @children = @lipid.children
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lipid
      @lipid = Lipid.find(params[:id])
    end
end
