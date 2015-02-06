module Car
  class Trim < ActiveRecord::Base

    self.table_name = 'car_trims'

    belongs_to :model
    has_one :maker, :through => :model
    has_one :brand, :through => :maker

    has_many :colors, through: :model
    has_many :prices
    has_many :tenders, inverse_of: :car_trim
  end
end