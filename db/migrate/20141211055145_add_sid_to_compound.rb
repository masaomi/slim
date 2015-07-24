class AddSidToCompound < ActiveRecord::Migration
  def change
    add_column :compounds, :sid, :string
  end
end
