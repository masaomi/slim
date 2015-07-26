class Change < ActiveRecord::Migration
  def change
    change_column :lipids, :systematic_name, :longtext
  end
end
