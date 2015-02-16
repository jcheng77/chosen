class AddBrandIdSerialIdToXcarShortComments < ActiveRecord::Migration
  def change
    add_column :xcar_short_comments, :brand_id, :integer
    add_column :xcar_short_comments, :serial_id, :integer
  end
end
