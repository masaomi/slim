class AddOxidationInfoToLipids < ActiveRecord::Migration
  def change
    add_column :lipids, :oxidations, :integer
    add_column :lipids, :oxvariant, :integer
    add_column :lipids, :parent, :string
    add_column :lipids, :molfile, :string
  end
end
