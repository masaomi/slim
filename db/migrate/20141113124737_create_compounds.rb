class CreateCompounds < ActiveRecord::Migration
  def change
    create_table :compounds do |t|
      t.string :compound
      t.string :compound_id
      t.string :adducts
      t.float :score
      t.float :fragmentation_score
      t.float :mass_error
      t.float :isotope_similarity
      t.float :retention_time
      t.string :link
      t.string :description
      t.references :quant, index: true
      t.references :lipid, index: true

      t.timestamps
    end
  end
end
