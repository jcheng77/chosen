class AddVehicleIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :vehicle_id, :integer
  end
end
