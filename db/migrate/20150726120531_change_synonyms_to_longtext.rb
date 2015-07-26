class ChangeSynonymsToLongtext < ActiveRecord::Migration
  def change
    change_column :lipids, :synonyms, :longtext
  end
end
