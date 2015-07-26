class AddIndexesToTable < ActiveRecord::Migration
  def change
    add_index :lipids, :pubchem_sid
    add_index :compounds, :compound
  end
end
