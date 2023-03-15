class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  has_many :results

  before_save :add_checksum

  def add_checksum
    self.checksum = (Digest::SHA2.new << "#{self.runner_name}-#{self.surname}-#{self.dob.to_date.year}").to_s
  end
end
