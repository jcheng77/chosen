class CreateCarModels < ActiveRecord::Migration
  def change
    create_table :car_models do |t|
    	t.string :name
    	t.integer :year
    	t.references :maker

      t.timestamps
    end
  end
end
