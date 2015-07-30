class FilterController < ApplicationController
  include FilterHelper
  def edit
    # for histograms
    @criteria = FilteringCriteria.new(session)
    if not params['minimal'].nil?
      print 'saving filtering'
      #first save absolute filtering criteria
      ['score','fragmentation_score','isotope_similarity','mass_error','adducts'].each do |crit|
        @criteria.minimal[crit] = params['minimal'][crit].to_f
      end
      @criteria.relative.sort! {|a,b| params['relative'][a] <=> params[:relative][b]}
      @criteria.oxichain! params['oxichain']
      @criteria.save session
    end
  end

  def list
    @criteria = FilteringCriteria.new session
    @samples = Sample.to_hash
  end

  def get_list
    @criteria = FilteringCriteria.new session
    @results = filteredIdentifications(@criteria)
    #@results = [Identification.find(383093),Identification.find(384995),Identification.find(382925)]
    @criteria.save(session)
    @oxichains = {}
    features = {}
    @results.each do |id|
       @oxichains[id.feature.oxichain] = id.lipid.parent
       features[id.feature.id] = true
    end
    unless @criteria.oxichain==false
      @oxifeatures = Feature.includes(:identifications, :quantifications).where(oxichain: @oxichains.keys).where.not(id: features.keys).where ('oxichain IS NOT NULL')
    else
      @oxifeatures = []
    end

    render layout:false
  end

  def statistics
    score_list = []
    frag_score_list = []
    iss_list = []
    adducts_list = []
    mass_error_list = []
    Identification.find_each do |ident|
      score_list << ident.score
      frag_score_list << ident.fragmentation_score
      iss_list << ident.isotope_similarity
      adducts_list << ident.adducts
      mass_error_list << ident.mass_error
    end

    score_dist = score_list.distribution
    frag_score_dist = frag_score_list.distribution
    iss_dist = iss_list.distribution
    adducts_dist = adducts_list.distribution("integer")
    mass_error_dist = mass_error_list.distribution()

    # sort
    @score_dist = Hash[*score_dist.sort_by{|key, value| key.first.to_f}.flatten]
    @frag_score_dist = Hash[*frag_score_dist.sort_by{|key, value| key.first.to_f}.flatten]
    @iss_dist = Hash[*iss_dist.sort_by{|key, value| key.first.to_f}.flatten]
    @adducts_size_dist = Hash[*adducts_dist.sort_by{|key, value| key.first.to_f}.flatten]
    @mass_error_dist = Hash[*mass_error_dist.sort_by{|key, value| key.first.to_f}.flatten]

    #session['score_dist'] = Hash[*score_dist.sort_by{|key, value| key.first.to_f}.flatten]
    #session['frag_score_dist'] = Hash[*frag_score_dist.sort_by{|key, value| key.first.to_f}.flatten]
    #session['iss_dist'] = Hash[*iss_dist.sort_by{|key, value| key.first.to_f}.flatten]
    #session['adducts_size_dist'] = Hash[*adducts_dist.sort_by{|key, value| key.first.to_f}.flatten]
    #session['mass_error_dist'] = Hash[*mass_error_dist.sort_by{|key, value| key.first.to_f}.flatten]

    @score_list = [score_list.min, score_list.max, score_list.ave, score_list.sd]
    @frag_score_list = [frag_score_list.min, frag_score_list.max, frag_score_list.ave, frag_score_list.sd]
    @iss_list = [iss_list.min, iss_list.max, iss_list.ave, iss_list.sd]
    @adducts_list = [adducts_list.min, adducts_list.max, adducts_list.ave, adducts_list.sd]
    @mass_error_list = [mass_error_list.min, mass_error_list.max, mass_error_list.ave, mass_error_list.sd]

    render layout:false
  end

  def csv
    criteria = FilteringCriteria.new(session)
    identifications = filteredIdentifications(criteria)
    samples = Sample.to_hash
    criteria.save(session)
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
    csv_headers.concat(samples.keys.map{|sample| Sample.find(sample).short}.map{|header| "#{header}_raw"}).concat(samples.keys.map{|sample| Sample.find(sample).short}.map{|header| "#{header}_norm"})
    csv_string = CSV.generate do |out|
      out << csv_headers
      identifications.each do |identification|
        result = []
        feature_description.each do |header|
          case header
            when 'feature'
              result << identification.feature.id_string
            when 'retention_time'
              result << identification.feature.rt
            when 'mass'
              result << identification.feature.m_z
              #don't do anything, we have already added these parameters in feature
            when 'lipid'
              result << identification.lipid.lm_id
            when 'parent_lipid'
              result << identification.lipid.parent
            when 'common_name'
              result << identification.lipid.common_name
            when 'oxidations'
              result << "%0i"%identification.lipid.oxidations
            when 'score'
              result << "%.4f"%identification.score
            when 'fragmentation_score'
              result << "%.4f"%identification.fragmentation_score
            when 'mass_error'
              result << "%.6f"%identification.mass_error
            when 'isotope_similarity'
              result << "%.6f"%identification.isotope_similarity
            when 'category'
              result << identification.lipid.sub_class
              if identification.lipid.sub_class =~/\[(\w\w)(\d\d)(\d\d)\]/
                result << $1
                result << $1+$2
                result << $1+$2+$3
              else
                result << ""
                result << ""
                result << identification.lipid.sub_class
              end
            when 'cat1','cat2','cat3'
              #don't do anything
            when 'n_identifications'
              result << Identification.where(feature: identification.feature).count
            else
              raise StandardError, 'cannot extract property %s from feature'%header
          end
        end
        quants = identification.feature.quants
        quants.each do |key, quant|
          result << "%.2f"%quant[0]
        end
        quants.each do |key, quant|
          result << "%.2f"%quant[1]
        end
        out << result
      end
    end
    criteria.save(session)
    send_data csv_string,
              :type => 'text/csv',
              :disposition => "attachment; filename=%s_results.csv"%Time.now.to_formatted_s(:number)
  end
end
