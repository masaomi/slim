class ImportLipidsController < ApplicationController
  def import
    session['lipid_count'] = nil
    first_line = true
    if file = params[:file] and sdf = file[:name]
      data = {}
      key = nil
      count = 0
      lipids = []
      category_names = {}
      File.readlines(sdf.path).each do |line|
        if first_line
          key = 'LM_ID'
          data[key] = line.chomp
          first_line = false
        end
        if key and key != 'LM_ID'
          data[key] = line.chomp
          key = nil
        end
        if line =~ /\<(.+)\>/
          key = $1
        end
        if line =~ /\$\$\$\$/
          count += 1
          lipid = Lipid.new
          lipid.lm_id = data['LM_ID']
          lipid.systematic_name = data['SYSTEMATIC_NAME']
          #lipid.pubchem_substane_url = data['PUBCHEM_SUBSTANE_URL']
          lipid.pubchem_substane_url = "http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=#{data['PUBCHEM_SID']}"
          #lipid.lipid_maps_cmpd_url = data['LIPID_MAPS_CMPD_URL']
          lipid.lipid_maps_cmpd_url = "http://www.lipidmaps.org/data/LMSDRecord.php?LMID=#{data['LM_ID']}"
          lipid.common_name = data['COMMON_NAME']
          lipid.synonyms = data['SYNONYMS']
          lipid.category_ = data['CATEGORY']
          category_names[data['CATEGORY']] = true
          lipid.main_class = data['MAIN_CLASS']
          lipid.sub_class = data['SUB_CLASS']
          lipid.exact_mass = data['EXACT_MASS']
          lipid.formula = data['FORMULA']
          lipid.pubchem_sid = data['PUBCHEM_SID'] 
          lipid.pubchem_cid = data['PUBCHEM_CID']
          lipid.kegg_id = data['KEGG_ID']
          lipid.chebi_id = data['CHEBI_ID']
          lipid.inchi_key = data['INCHI_KEY']
          lipid.status = data['STATUS']
          lipids << lipid
#          lipid.save
          first_line = true
        end
      end
      Lipid.import lipids

      categories = []
      category_names.keys.each do |category_name|
        category = Category.new
        category.name = category_name
        categories << category
      end
      Category.import categories
      name2category = {}
      Category.find_each do |category|
        name2category[category.name] = category
      end
      Lipid.find_each do |lipid|
        if category = name2category[lipid.category_]
          category.lipids << lipid
        end
      end

      #render :text => data.to_a.map{|a,b| "#{a}:#{b}"}.join("<br>\n")
      #render :text => "#{count} lipids imported"
      #render :text => "#{count} lipids imported, #{categories.length} categories imported"
      @comment = "#{count} lipids imported, #{categories.length} categories imported"
    else
      render :text => 'file upload failed'
    end
  end
end
