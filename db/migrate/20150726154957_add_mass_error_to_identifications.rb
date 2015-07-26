class AddMassErrorToIdentifications < ActiveRecord::Migration
  def change
    add_column :identifications, :mass_error, :float
  end
end
