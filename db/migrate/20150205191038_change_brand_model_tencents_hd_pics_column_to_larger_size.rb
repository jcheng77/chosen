class ChangeBrandModelTencentsHdPicsColumnToLargerSize < ActiveRecord::Migration
  def change
    change_column :brand_model_tencents, :hd_pics, :string, :limit => 1000
  end
end
