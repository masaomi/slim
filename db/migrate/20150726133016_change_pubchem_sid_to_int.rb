class ChangePubchemSidToInt < ActiveRecord::Migration
  def change
    change_column :lipids, :pubchem_sid, :integer, limit: 8
  end
end
