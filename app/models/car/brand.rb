module Car
  class Brand < ActiveRecord::Base

    self.table_name = 'car_brands'

    has_many :makers
    has_many :models, through: :makers
    has_many :trims, through: :models
    has_and_belongs_to_many :shops, :join_table => "brands_shops"

  end
end