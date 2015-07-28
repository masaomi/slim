class FeaturesController < ApplicationController
  include ActionController::Live

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
    unless @idents.keys.count == 0
      ActiveRecord::Base.connection.execute('SELECT feature_id FROM identifications WHERE feature_id IN (%s)'%@idents.keys.join(",")).each do |id|
        @idents[id[0].to_i] += 1
      end
    end
  end

  def plot_2d
  end

  def load_features
    response.headers['Content-Type'] = 'text/event-stream'
    response.stream.write(": starting up stream\n\n")
    Feature.all.order(m_z: :asc).each do |feature|
      color = "#000088"
      response.stream.write("data: [{m_z:#{feature.m_z},rt:#{feature.rt},id:#{feature.id},color:'#{feature.oxichain? ? '#880000': color}', oxichain:#{feature.oxichain.nil? ? 'null' : feature.oxichain}}]\n\n")
    end
  ensure
    response.stream.close
  end

  def show
    @feature = Feature.find(params[:feature])
  end
  def oxichain

  end
  def oxichain_find
    response.headers['Content-Type'] = 'text/event-stream'
    def log(data)
      response.stream.write("data: #{data}\n\n")
    end
    def search_upwards(feature)
      features = Feature.where('m_z > ? and m_z < ? and rt > ? and rt < ? and oxichain is NULL',
                    feature.m_z+15.993915,feature.m_z+15.995915,
                     feature.rt-2,feature.rt-0.2)
      return nil if features.nil?
      best = nil
      features.each do |f|
        if best.nil?
          best = f
          next
        end
        best = f if (best.m_z-15.994915-feature.m_z).abs > (f.m_z-15.994915-feature.m_z).abs
      end
      return best
    end
    def search_downwards(feature)
      features = Feature.where('m_z < ? and m_z > ? and rt < ? and rt > ? and oxichain is NULL',
                    feature.m_z-15.993915,feature.m_z-15.995915,
                     feature.rt+2,feature.rt+0.2)
      return nil if features.nil?
      best = nil
      features.each do |f|
        if best.nil?
          best = f
          next
        end
        best = f if (best.m_z+15.994915-feature.m_z).abs > (f.m_z+15.994915-feature.m_z).abs
      end
      return best
    end
    log('deleting old oxichain information')
    c = Feature.count
    n = 0
    total_oxichain = 0
    Feature.all.update_all(oxichain:nil)
    log("    ....   #{c} features to go through ....")
    oxichain = 1
    Feature.all.each do |feature|
      n += 1
      members = 1
      up = search_upwards(feature)
      until up.nil?
        up.oxichain = oxichain
        up.save!
        members += 1
        up = search_upwards(up)
      end
      down = search_downwards(feature)
      until down.nil?
        down.oxichain = oxichain
        down.save!
        members += 1
        down = search_downwards(down)
      end
      if members > 1
        feature.oxichain = oxichain
        feature.save
        total_oxichain += members
        log("  > Found oxichain #{oxichain} with #{members} member-features starting with feature <a href='#{feature_path(feature)}'>#{feature.id_string}</a>.")
        oxichain += 1
      end
      if n%200==0
        log("(#{"%.0f"%(100.0*n/c)}%)    ....   done with #{n} of #{c} features  ....")
      end
    end
    log("100%! Terminated oxichain search - found total #{total_oxichain} of #{c} features in an oxichain (#{"%.1f"%(100.0*total_oxichain/c)}%)")
  rescue
    response.stream.write("data: ABORTED! An error occured: #{$!}")
    raise
  ensure
    response.stream.close
  end

end
