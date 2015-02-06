class CreateCarModelsShops < ActiveRecord::Migration
  def change
    create_table :car_models_shops do |t|
      t.integer :model_id
      t.integer :shop_id
    end
  end
end
