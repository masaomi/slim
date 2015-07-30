class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.string :id_string
      t.string :short

      t.timestamps
    end
    change_column :samples, :id_string, :longtext
  end
end
