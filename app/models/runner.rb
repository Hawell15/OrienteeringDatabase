class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  has_many :results
end
