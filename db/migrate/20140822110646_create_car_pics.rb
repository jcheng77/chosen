class CreateCarPics < ActiveRecord::Migration
  def change
    create_table :car_pics do |t|
    	t.string :pic_url
    	t.references :model

      t.timestamps
    end
  end
end
