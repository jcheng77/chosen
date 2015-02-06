module Car
  class Color < ActiveRecord::Base

    self.table_name = 'car_colors'

    belongs_to :model
    has_many :tenders, inverse_of: :car_color

  end
end