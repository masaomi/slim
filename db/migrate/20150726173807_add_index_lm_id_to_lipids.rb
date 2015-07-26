class AddIndexLmIdToLipids < ActiveRecord::Migration
  def change
    add_index :lipids, :lm_id
  end
end
