class AddAdductsSizeToCompound < ActiveRecord::Migration
  def change
    add_column :compounds, :adducts_size, :integer
  end
end
