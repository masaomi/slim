class IndexOverFeatureId < ActiveRecord::Migration
  def change
    add_index :features, :id_string
  end
end
