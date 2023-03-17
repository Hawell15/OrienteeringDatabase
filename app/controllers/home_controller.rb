class HomeController < ApplicationController
  def index
    # runners = []
    # options = [{ gender: "MEN", type: "F" }, { gender:"MEN", type:"FS" }, { gender:"WOMEN", type:"F" }, { gender:"WOMEN", type:"FS" }]

    # options.each do |option|
    #   gender = option[:gender] == "MEN" ? "M" : "F"
    #   runners += persons(option, gender)
    # end

# url = "https://ranking.orienteering.org/download.ashx?doctype=rankfile&rank=#{option[:type]}&group=#{option[:gender]}&todate=2023-03-17&ioc=MDA"

# csv_data = URI.open(url).read
# csv = Roo::CSV.new(StringIO.new(csv_data), csv_options: { col_sep: ';' })
# headers_index = parse_headers(csv.first)
# csv.drop(1).each do |row|
#   byebug
# end

# # parsed_csv.each do |row|
#   # Do something with each row of the CSV data
#   # byebug
# # end

  end

  def get_groups
    # @group = Group.where(competition_id: params[:comp_id])
    # render json: @group
  end

  # private

  # def parse_headers(row)
  #   headers = {}
  #   row.each_with_index do |cell, index|
  #     key = case cell
  #     when "IOF ID"       then :wre_id
  #     when "First Name"   then :surname
  #     when "Last Name"    then :runner_name
  #     when "WRS Position" then :wre_place
  #     when "WRS points"   then :wre_rang
  #     else next
  #     end
  #     headers[key] = index
  #   end
  #   headers
  # end

  # def persons(option, gender)
  #   url = "https://ranking.orienteering.org/download.ashx?doctype=rankfile&rank=#{option[:type]}&group=#{option[:gender]}&todate=2023-03-17&ioc=MDA"

  #   csv_data      = URI.open(url).read
  #   csv           = Roo::CSV.new(StringIO.new(csv_data), csv_options: { col_sep: ';' })
  #   headers_index = parse_headers(csv.first)

  #   csv.drop(1).each do |row|
  #     hash = {
  #       surname:     row[headers_index[:surname],
  #       runner_name: row[headers_index[:runner_name],
  #       wre_id:      row[headers_index[:wre_id].to_i,
  #       gender:      gender,
  #       club_id:     0,
  #       category_id: 10
  #     }

  #     if option[:type] == "F"
  #       {
  #         forest_wre_rang:  row[headers_index[:wre_place],
  #         forest_wre_place: row[headers_index[:wre_place]
  #       }
  #     else
  #       {
  #         sprint_wre_rang:  row[headers_index[:wre_place],
  #         sprint_wre_place: row[headers_index[:wre_place]
  #       }
  #     end.merge(hash)
  #   end
  # end
end
