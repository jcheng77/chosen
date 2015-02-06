class CreateCarMakers < ActiveRecord::Migration
  def change
    create_table :car_makers do |t|
    	t.string :name
    	t.references :brand

    	t.timestamps
    end
  end
end
