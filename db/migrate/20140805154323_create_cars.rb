class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :name
      t.string :model
      t.decimal :price, precision: 12, scale: 2

      t.timestamps
    end
  end
end
