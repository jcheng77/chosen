class CreateCarTrims < ActiveRecord::Migration
  def change
    create_table :car_trims do |t|
    	t.string :name
    	t.references :model
    	t.decimal :guide_price, precision: 12, scale: 2

      t.timestamps
    end
  end
end
