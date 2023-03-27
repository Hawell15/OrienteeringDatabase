class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  has_many :results

  before_save :add_checksum

 scope :matching_runner, ->(options) {
    where("wre_id = :wre_id or id = :id or checksum = :checksum",
      wre_id: options[:wre_id],
      id: options[:id],
      checksum: get_checksum(options[:runner_name], options[:surname], options[:dob]))
  }

  def self.get_runner(options)
    runner = matching_runner(options).first

    return runner if runner

    runner = get_runner_by_matching(options)

    return runner if runner

    Runner.create!(options)
  end

  def get_checksum(runner_name, surname, dob)
    @checksum ||= (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}").to_s
  end

  def self.get_checksum(runner_name, surname, dob)
    (Digest::SHA2.new << "#{runner_name}-#{surname}-#{dob.to_date.year}").to_s
  end


  private

  def add_checksum
    self.checksum = get_checksum(self.runner_name, self.surname, self.dob)
  end

  def self.get_runner_by_matching(options)
    threshold = 0.8
    runners = Runner.all.map do |runner|
      name_threshold = Text::Levenshtein.distance(runner.runner_name.downcase, options[:runner_name].downcase) / runner.runner_name.length.to_f
      surname_threshold = Text::Levenshtein.distance(runner.surname.downcase, options[:surname].downcase) / runner.surname.length.to_f
      next nil unless (name_threshold + surname_threshold)/2 < (1 -threshold)

      [(name_threshold + surname_threshold)/2, runner]
    end
    runners.compact.max_by { |el| el.first}&.last
  end
end
