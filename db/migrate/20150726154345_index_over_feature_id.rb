class IndexOverFeatureId < ActiveRecord::Migration
  def change
    add_index :features, :id_string
    add_index :lipids, :lm_id
    add_index :lipids, :common_name
    add_index :lipids, :pubchem_sid
  end
end
