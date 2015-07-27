class CreateLipids < ActiveRecord::Migration
  def change
    create_table :lipids do |t|
      t.string :lm_id
      t.string :pubchem_substane_url
      t.string :lipid_maps_cmpd_url
      t.string :common_name
      t.string :systematic_name, limit:512
      t.string :synonyms, limit:1024
      t.string :category_
      t.string :main_class
      t.string :sub_class
      t.float :exact_mass
      t.string :formula
      t.integer :pubchem_sid, limit: 8
      t.string :pubchem_cid
      t.string :kegg_id
      t.string :chebi_id
      t.string :inchi_key
      t.string :status
      t.text :molfile
      t.integer :oxidations
      t.integer :oxvariant
      t.string :parent

      t.timestamps
    end
  end
end
