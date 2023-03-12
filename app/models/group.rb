class Group < ApplicationRecord
  has_many :results
  belongs_to :competition
end
