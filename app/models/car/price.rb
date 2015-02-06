module Car
  class Price < ActiveRecord::Base

	self.table_name = 'car_prices'
	belongs_to :trim

  end
end
