class CreateQuantifications < ActiveRecord::Migration
  def change
    create_table :quantifications do |t|
      t.references :feature
      t.references :sample
      t.float :norm
      t.float :raw

      t.timestamps
    end
  end
end
