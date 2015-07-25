# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'


#sdf_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/pc_oxidized.sdf"
sdf_path =  Rails.env.production? ? "sample_data/LARGE_LM_oxidized.sdf" : "sample_data/pc_oxidized.sdf"
#compound_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_IDs_small.csv"
compound_csv_path = "sample_data/COMPOUND_IDs.csv"
#quant_csv_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/COMPOUND_quantities_small.csv"
quant_csv_path = "sample_data/COMPOUND_quantities.csv"

# Import lipids
t0 = Time.now
include ImportLipidsHelper
puts importSDF(sdf_path)
puts "Time: #{"%.2f" % (Time.now - t0)} [s]"
t0 = Time.now

# Identifications
include ImportCompoundsHelper
puts importIdentifications(compound_csv_path)
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
threads = []
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
