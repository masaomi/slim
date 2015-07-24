# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'


#sdf_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/pc_oxidized.sdf"
sdf_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/allLipids_oxidized.sdf"
#compound_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_IDs_small.csv"
compound_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_IDs.csv"
#quant_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_quantities_small.csv"
quant_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_quantities.csv"

# Import lipids
t0 = Time.now
first_line = true
data = {}
key = nil
count = 0
lipids = []
category_names = {}
File.readlines(sdf_path).each do |line|
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
puts "#{count} lipids imported, #{categories.length} categories imported"
puts "Time: #{"%.2f" % (Time.now - t0)} [s]"
t0 = Time.now

# Compound
count = 0
count_lipid = 0
compounds = []
CSV.foreach(compound_csv_path, :headers=>true, :col_sep=>";") do |row|
  record = {}
  row.each do |key, value|
    record[key.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_')] = value
  end

  sid = if record['link'] =~ /sid=(\d+)/
          $1
        end
  sid = sid.to_s
  count += 1
  compound = Compound.new
  compound.compound = record['compound']
  compound.compound_id = record['compound_id']
  compound.adducts = record['adducts']
  compound.adducts_size = record['adducts'].split(/,/).length
  compound.score = record['score'].to_f
  compound.fragmentation_score = record['fragmentation_score'].to_f
  compound.mass_error = record['mass_error'].to_f
  compound.isotope_similarity = record['isotope_similarity'].to_f
  compound.retention_time = record['retention_time'].to_f
  compound.sid = sid
  compound.link = record['link']
  compound.description = record['description']
  #compound.save
  compounds << compound
end
Compound.import compounds

sid2lipid = {}
Lipid.find_each do |lipid|
  sid2lipid[lipid.pubchem_sid] ||= []
  sid2lipid[lipid.pubchem_sid] << lipid
end
unlinked_compounds = 0
Compound.find_each do |compound|
  #if lipid = Lipid.find_by_pubchem_sid(compound.sid)
  if lipids = sid2lipid[compound.sid] and lipid = lipids.first
    count_lipid += 1
    #compound.lipid = lipid
    lipid.compounds << compound
  else
    compound.delete
    unlinked_compounds += 1
  end
end
puts "#{count} compounds imported, compounds with sid linked to lipids: #{count_lipid}, unlinked compounds deleted: #{unlinked_compounds}"
puts "Time: #{"%.2f" % (Time.now - t0)} [s]"
t0 = Time.now

# Quant
compound_name2compound = {}
Compound.find_each do |compound|
  compound_name2compound[compound.compound] ||= []
  compound_name2compound[compound.compound] << compound
end

#compound_all = Compound.select("compound").all.uniq
count = 0
total = 0
quants = []
CSV.foreach(quant_csv_path, :headers=>true, :col_sep=>";") do |row|
  total += 1
  record = {}
  row.each do |key, value|
    # puts [key, value].join(" ")
    new_key = key.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_')
    record[new_key] ||= []
    record[new_key] << value
  end
  #if compound = record['compound'] and compound = compound.first and Compound.find_by_compound(compound)
  if compound = record['compound'] and compound = compound.first and compound_name2compound[compound]
    count += 1
  #if compound = record['compound'] and compound = compound.first and compound_all.include?(compound)
    quant = Quant.new
    #quant.compound = record['compound'].first
    quant.compound = compound
    samples = {}
    record.each do |key, values|
      if key =~ /mp_\d+/
        samples[key] = values
      end
    end
    quant.samples = samples.to_s
    #quant.save
    quants << quant
  end
end
Quant.import quants

Quant.find_each do |quant|
  compound_name2compound[quant.compound].to_a.each do |compound|
    #compound.quant = quant
    #compound.quant.compounds << compound
    quant.compounds << compound
  end
end

puts "#{count} compounds imported / total #{total} loaded "
puts "Time: #{"%.2f" % (Time.now - t0)} [s]"
