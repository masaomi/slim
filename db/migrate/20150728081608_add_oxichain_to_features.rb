class AddOxichainToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :oxichain, :integer
  end
end
