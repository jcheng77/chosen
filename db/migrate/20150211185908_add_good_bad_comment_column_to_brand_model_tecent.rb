class AddGoodBadCommentColumnToBrandModelTecent < ActiveRecord::Migration
  def change
    add_column :brand_model_tencents, :good_comments, :string
    add_column :brand_model_tencents, :bad_comments, :string
  end
end
