class AddHdPicToXcarShortComments < ActiveRecord::Migration
  def change
    add_column :xcar_short_comments, :hd_pic, :string
  end
end
