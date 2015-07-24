# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141211133910) do

  create_table "compounds", force: true do |t|
    t.string   "compound"
    t.string   "compound_id"
    t.string   "adducts"
    t.float    "score"
    t.float    "fragmentation_score"
    t.float    "mass_error"
    t.float    "isotope_similarity"
    t.float    "retention_time"
    t.string   "link"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.integer  "adducts_size"
  end

  create_table "lipids", force: true do |t|
    t.string   "lm_id"
    t.string   "pubchem_substane_url"
    t.string   "lipid_maps_cmpd_url"
    t.string   "common_name"
    t.string   "systematic_name"
    t.string   "synonyms"
    t.string   "category"
    t.string   "main_class"
    t.string   "sub_class"
    t.float    "exact_mass"
    t.string   "formula"
    t.string   "pubchem_sid"
    t.string   "pubchem_cid"
    t.string   "kegg_id"
    t.string   "chebi_id"
    t.string   "inchi_key"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quants", force: true do |t|
    t.string   "compound"
    t.string   "samples"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
