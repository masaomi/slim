include ImportCompoundsHelper
class ImportCompoundsController < ApplicationController
  def import
    session['compound_count'] = nil
    if file = params[:file] and csv = file[:name]
      @comment = importIdentifications(csv.path)
    else
      render :text => 'file upload failed'
    end
  end
end
