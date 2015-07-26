class ChangeMolfileLipid < ActiveRecord::Migration
  def change
     change_column :lipids, :molfile, :longtext
  end
end
