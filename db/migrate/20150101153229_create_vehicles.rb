class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :brand
      t.string :model
      t.float :lowest_price
      t.float :highest_price
      t.string :image_url

      t.timestamps
    end
  end
end
