class Group < ApplicationRecord
  has_many :results
  belongs_to :competition

  accepts_nested_attributes_for :competition

end
