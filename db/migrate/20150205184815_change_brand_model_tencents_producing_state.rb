class ChangeBrandModelTencentsProducingState < ActiveRecord::Migration
  def change
    rename_column :brand_model_tencents, :serial_producting_state, :serial_producing_state
  end
end
