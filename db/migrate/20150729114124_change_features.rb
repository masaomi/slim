class ChangeFeatures < ActiveRecord::Migration
  def change
    change_column :features, :m_z, :decimal, :precision => 15, :scale => 10
    change_column :features, :rt, :decimal, :precision => 12, :scale => 9
    change_column :features, :mass, :decimal, :precision => 15, :scale => 10
  end
end
