class CreateXcarShortComments < ActiveRecord::Migration
  def change
    create_table :xcar_short_comments do |t|
      t.string :brand_name
      t.string :serial_name
      t.string :good_comments
      t.string :short_comments

      t.timestamps
    end
  end
end
