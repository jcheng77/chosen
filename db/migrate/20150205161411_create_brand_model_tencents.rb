class CreateBrandModelTencents < ActiveRecord::Migration
  def change
    create_table :brand_model_tencents do |t|
      t.integer :brand_id
      t.string :brand_name
      t.string :first_letter
      t.string :brand_logo
      t.string :brand_country
      t.integer :man_id
      t.string :man_name
      t.integer :serial_id
      t.string :serial_name
      t.string :serial_pic
      t.string :serial_first
      t.float :serial_low_price
      t.float :serial_high_price
      t.string :serial_lever
      t.string :serial_country
      t.string :serial_displace
      t.string :serial_producting_state
      t.string :serial_video
      t.string :serial_use_way
      t.string :serial_competion
      t.string :hd_pics

      t.timestamps
    end
  end
end
