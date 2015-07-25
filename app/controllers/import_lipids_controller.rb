class ImportLipidsController < ApplicationController
  include ImportLipidsHelper
  def import
    session['lipid_count'] = nil
    first_line = true
    if file = params[:file] and sdf = file[:name]
      @comment = importSDF(sdf.path)
    else
      render :text => 'file upload failed'
    end
  end
end
