class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.float :rt
      t.float :m_z
      t.float :mass
      t.integer :charge
      t.string :id_string

      t.timestamps
    end
  end
end