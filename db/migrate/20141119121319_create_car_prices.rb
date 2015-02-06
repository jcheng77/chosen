class CreateCarPrices < ActiveRecord::Migration
  def change
    create_table :car_prices do |t|
      t.date :offering_date
      t.decimal :price
	  t.references :trim

      t.timestamps
    end
  end
end
