class Result < ApplicationRecord
  belongs_to :runner
  belongs_to :category
  belongs_to :group

  accepts_nested_attributes_for :group
end
