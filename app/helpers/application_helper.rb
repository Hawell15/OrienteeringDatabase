module ApplicationHelper
  def add_competition(hash)
    byebug
    if hash["date(1i)"]
      hash[:date] = "#{hash["date(1i)"]}-#{hash["date(2i)"]}-#{hash["date(3i)"]}"
    end

    comp = Competition.new(hash.slice(:competition_name, :date, :location, :country, :distance_type, :wre_id))
  end
end
