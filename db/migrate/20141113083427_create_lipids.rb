class CreateLipids < ActiveRecord::Migration
  def change
    create_table :lipids do |t|
      t.string :lm_id
      t.string :pubchem_substane_url
      t.string :lipid_maps_cmpd_url
      t.string :common_name
      t.string :systematic_name
      t.string :synonyms
      t.string :category_
      t.string :main_class
      t.string :sub_class
      t.float :exact_mass
      t.string :formula
      t.string :pubchem_sid
      t.string :pubchem_cid
      t.string :kegg_id
      t.string :chebi_id
      t.string :inchi_key
      t.string :status
      t.references :category, index: true

      t.timestamps
    end
  end
end
