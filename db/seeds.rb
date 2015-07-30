# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'rake'
#Rake::Task['import:sdf'].invoke()   # <-- do this manually!

=begin
#sdf_path = "/srv/GT/analysis/masaomi/slim/proto-slim2-dev/sample_data/pc_oxidized.sdf"
sdf_path =  true ? "sample_data/LARGE_LM_oxidized.sdf" : "sample_data/pc_oxidized.sdf"
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


puts "Time: #{"%.2f" % (Time.now - t0)} [s]"
=end
