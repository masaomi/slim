class CreateIdentifications < ActiveRecord::Migration
  def change
    create_table :identifications do |t|
      t.references :feature
      t.references :lipid
      t.float :fragmentation_score
      t.float :score
      t.float :isotope_similarity
      t.integer :adducts
      t.integer :priority

      t.timestamps
    end
  end
end
