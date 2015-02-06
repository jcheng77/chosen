module Car
  class Maker < ActiveRecord::Base

    self.table_name = 'car_makers'

    belongs_to :brand
    has_many :models

  end
end