class AddLipidsCommonNameIndex < ActiveRecord::Migration
  def change
    add_index :lipids, :common_name
  end
end
