class FeaturesController < ApplicationController
  def index
    @features_count = Feature.count
    @features = Feature.page params[:page]
    @page = params[:page]
    if @page
      @start = 300*(@page.to_i-1)+1
    else
      @start = 1
    end
    @end = if @features_count < @start+300
             @features_count
           else
             @start + 300 - 1
           end
    @idents= {}
    @features.each do |feature|
       @idents[feature.id] = 0
    end
    ActiveRecord::Base.connection.execute('SELECT feature_id FROM identifications WHERE feature_id IN (%s)'%@idents.keys.join(",")).each do |id|
       @idents[id] += 1
    end


  end

  def show
    @feature = Feature.find(params[:feature])
  end
end
