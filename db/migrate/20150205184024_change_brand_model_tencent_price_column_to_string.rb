class ChangeBrandModelTencentPriceColumnToString < ActiveRecord::Migration
  def change
    change_column :brand_model_tencents, :serial_low_price, :string
    change_column :brand_model_tencents, :serial_high_price, :string
  end
end
