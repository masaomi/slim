class CreateQuants < ActiveRecord::Migration
  def change
    create_table :quants do |t|
      t.string :compound
      t.string :samples

      t.timestamps
    end
  end
end
