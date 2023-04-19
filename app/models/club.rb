class Club < ApplicationRecord
  has_many :runners
  has_many :users
end
