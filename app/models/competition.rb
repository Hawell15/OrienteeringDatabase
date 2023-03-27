class Competition < ApplicationRecord
  has_many :groups

  before_save :add_checksum

  def add_checksum
    self.checksum = (Digest::SHA2.new << "#{self.competition_name}-#{self.date.as_json}-#{self.distance_type}").to_s
  end
end
