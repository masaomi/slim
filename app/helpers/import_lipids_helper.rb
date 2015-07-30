module ImportLipidsHelper
  def importSDF(path)
    data = {}
    key = nil
    count = 0
    lipids = []
    first_line = true
    molfile = ""
    File.foreach(path).each do |line|
      if first_line
        if key.nil?
          key = 'LM_ID'
          data[key] = line.chomp
          molfile = ""
        end
        if line =~ /\<.+\>/
          first_line = false
          key = nil
        else
          molfile = molfile.concat(line) #without chomp, we need the newline.
          next
        end
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
        if count%1000==0
          puts "Imported Lipid ##{count}"
          Lipid.import lipids
          lipids = []
        end
        lipid = Lipid.new
        lipid.lm_id = data['LM_ID']
        lipid.molfile = molfile
        if lipid.lm_id =~ /([A-Z0-9]+)_(\d+)OX_V(\d+)/
          lipid.parent = $1
          lipid.oxidations = $2.to_i
          lipid.oxvariant = $3.to_i
        else
          lipid.parent = lipid.lm_id
          lipid.oxidations = 0
          lipid.oxvariant = 0
        end
        lipid.systematic_name = data['SYSTEMATIC_NAME']
        #lipid.pubchem_substane_url = data['PUBCHEM_SUBSTANE_URL']
        lipid.pubchem_substane_url = "http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=#{data['PUBCHEM_SID']}"
        #lipid.lipid_maps_cmpd_url = data['LIPID_MAPS_CMPD_URL']
        lipid.lipid_maps_cmpd_url = "http://www.lipidmaps.org/data/LMSDRecord.php?LMID=#{lipid.parent}"
        lipid.common_name = data['COMMON_NAME']
        lipid.synonyms = data['SYNONYMS']
        lipid.category_ = data['CATEGORY']
        lipid.main_class = data['MAIN_CLASS']
        lipid.sub_class = data['SUB_CLASS']
        lipid.exact_mass = data['EXACT_MASS']
        lipid.formula = data['FORMULA']
        lipid.pubchem_sid = data['PUBCHEM_SID'].to_i
        lipid.pubchem_cid = data['PUBCHEM_CID']
        lipid.kegg_id = data['KEGG_ID']
        lipid.chebi_id = data['CHEBI_ID']
        lipid.inchi_key = data['INCHI_KEY']
        lipid.status = data['STATUS']
        lipids << lipid
        #          lipid.save
        first_line = true
        key = nil
        data = {}
      end
    end
    Lipid.import lipids
    return("#{count} lipids imported" )
  end
end