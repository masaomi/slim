class QuantsController < ApplicationController
  before_action :set_quant, only: [:show, :edit, :update, :destroy]

  # GET /quants
  # GET /quants.json
  def index
    @quants_count = Quant.count
    @quants = Quant.page params[:page]
    @page = params[:page]
    if @page
      @start = 100*(@page.to_i-1)+1
    else
      @start = 1
    end
    @end = if @quants_count < @start+100
             @quants_count
           else
             @start + 100
           end
=begin
    @samples_length = 0
    @quants.each do |quant|
      @samples_length += eval(quant.samples).length
    end
=end
  end

  # GET /quants/1
  # GET /quants/1.json
  def show
  end

  # GET /quants/new
  def new
    @quant = Quant.new
  end

  # GET /quants/1/edit
  def edit
  end

  # POST /quants
  # POST /quants.json
  def create
    @quant = Quant.new(quant_params)

    respond_to do |format|
      if @quant.save
        format.html { redirect_to @quant, notice: 'Quant was successfully created.' }
        format.json { render :show, status: :created, location: @quant }
      else
        format.html { render :new }
        format.json { render json: @quant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quants/1
  # PATCH/PUT /quants/1.json
  def update
    respond_to do |format|
      if @quant.update(quant_params)
        format.html { redirect_to @quant, notice: 'Quant was successfully updated.' }
        format.json { render :show, status: :ok, location: @quant }
      else
        format.html { render :edit }
        format.json { render json: @quant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quants/1
  # DELETE /quants/1.json
  def destroy
    @quant.destroy
    respond_to do |format|
      format.html { redirect_to quants_url, notice: 'Quant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_all
    Quant.delete_all
    session['quant_count'] = nil
    @comment = 'delete all quants'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quant
      @quant = Quant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quant_params
      params.require(:quant).permit(:compound, :samples)
    end
end
