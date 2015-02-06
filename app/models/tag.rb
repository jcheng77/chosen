class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :vehicles, through: :taggings
end
