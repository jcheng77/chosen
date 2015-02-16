class Vehicle < ActiveRecord::Base
  attr_reader :tag

  acts_as_taggable
  acts_as_taggable_on :category, :impression

  has_many :images

end
