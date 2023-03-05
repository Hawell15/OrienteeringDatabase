class Result < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :group
end
