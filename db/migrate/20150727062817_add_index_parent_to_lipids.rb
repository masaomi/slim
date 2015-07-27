class AddIndexParentToLipids < ActiveRecord::Migration
  def change
    add_index :lipids, :parent
  end
end
