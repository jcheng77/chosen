module Car
  class Pic < ActiveRecord::Base

    self.table_name = 'car_pics'
    belongs_to :model

  end
end