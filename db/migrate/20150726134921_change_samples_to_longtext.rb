class ChangeSamplesToLongtext < ActiveRecord::Migration
  def change
    change_column :quants, :samples, :longtext
  end
end
