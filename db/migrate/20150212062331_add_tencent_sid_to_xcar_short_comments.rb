class AddTencentSidToXcarShortComments < ActiveRecord::Migration
  def change
    add_column :xcar_short_comments, :tencent_sid, :integer
  end
end
