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

ActiveRecord::Schema.define(version: 20150726154957) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "compounds", force: true do |t|
    t.string   "compound"
    t.string   "compound_id"
    t.string   "adducts"
    t.float    "score",               limit: 24
    t.float    "fragmentation_score", limit: 24
    t.float    "mass_error",          limit: 24
    t.float    "isotope_similarity",  limit: 24
    t.float    "retention_time",      limit: 24
    t.string   "link"
    t.string   "description"
    t.integer  "quant_id"
    t.integer  "lipid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.integer  "adducts_size"
  end

  add_index "compounds", ["compound"], name: "index_compounds_on_compound", using: :btree
  add_index "compounds", ["lipid_id"], name: "index_compounds_on_lipid_id", using: :btree
  add_index "compounds", ["quant_id"], name: "index_compounds_on_quant_id", using: :btree

  create_table "features", force: true do |t|
    t.float    "rt",         limit: 24
    t.float    "m_z",        limit: 24
    t.float    "mass",       limit: 24
    t.integer  "charge"
    t.string   "id_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "features", ["id_string"], name: "index_features_on_id_string", using: :btree

  create_table "identifications", force: true do |t|
    t.integer  "feature_id"
    t.integer  "lipid_id"
    t.float    "fragmentation_score", limit: 24
    t.float    "score",               limit: 24
    t.float    "isotope_similarity",  limit: 24
    t.integer  "adducts"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "mass_error",          limit: 24
  end

  create_table "lipids", force: true do |t|
    t.string   "lm_id"
    t.string   "pubchem_substane_url"
    t.string   "lipid_maps_cmpd_url"
    t.string   "common_name"
    t.text     "systematic_name",      limit: 2147483647
    t.text     "synonyms",             limit: 2147483647
    t.string   "category_"
    t.string   "main_class"
    t.string   "sub_class"
    t.float    "exact_mass",           limit: 24
    t.string   "formula"
    t.integer  "pubchem_sid",          limit: 8
    t.string   "pubchem_cid"
    t.string   "kegg_id"
    t.string   "chebi_id"
    t.string   "inchi_key"
    t.string   "status"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "oxidations"
    t.integer  "oxvariant"
    t.string   "parent"
    t.text     "molfile",              limit: 2147483647
  end

  add_index "lipids", ["category_id"], name: "index_lipids_on_category_id", using: :btree
  add_index "lipids", ["pubchem_sid"], name: "index_lipids_on_pubchem_sid", using: :btree
  add_index "lipids", ["pubchem_sid"], name: "pubchem_sid", using: :btree

  create_table "quantifications", force: true do |t|
    t.integer  "feature_id"
    t.integer  "sample_id"
    t.float    "norm",       limit: 24
    t.float    "raw",        limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quants", force: true do |t|
    t.string   "compound"
    t.text     "samples",    limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", force: true do |t|
    t.text     "id_string",  limit: 2147483647
    t.string   "short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
