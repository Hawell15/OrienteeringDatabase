class WreController < ApplicationController

  def wre_ids
        time = Time.now
    options = [{ gender: "MEN", type: "F" }, { gender:"MEN", type:"FS" }, { gender:"WOMEN", type:"F" }, { gender:"WOMEN", type:"FS" }]
    threads = []
    runners = []

    options.each do |option|
      threads << Thread.new do
        gender = option[:gender] == "MEN" ? "M" : "F"
        runners += persons_csv(option, gender)
      end
    end
    threads.each(&:join)

    result = runners.group_by { |h| h[:wre_id] }.reduce([]) do |acc, (key, values)|
      acc << values.reduce do |merged_hash, current_hash|
        merged_hash.merge(current_hash)
      end
    end

    ids = result.pluck(:wre_id)

    existing_runners_by_id = Runner.where(wre_id: ids).pluck(:wre_id)
    existing_runners_by_id.each do |runner_id|
      res = result.detect { |r| r[:wre_id] == runner_id }.slice(:forest_wre_rang, :sprint_wre_rang, :forest_wre_place, :sprint_wre_place)
      Runner.where(wre_id: runner_id).update(res)
    end

    new_ids = ids - existing_runners_by_id
    new_runners = result.select { |rn| new_ids.include?(rn[:wre_id])}

    threads = []
    new_ids.each do |id|
      threads << Thread.new do
        url = "https://eventor.orienteering.org/Athletes/Details/#{id}"
        response = Nokogiri::HTML(RestClient.get(url).body)
        runner = new_runners.detect { |rn| rn[:wre_id] == id.to_i }
        runner[:dob]      = "#{response.at_css("tr:contains('Year of birth') td.athleteFactsInfo").text}-01-01"
        runner[:checksum] = (Digest::SHA2.new << "#{runner[:runner_name]}-#{runner[:surname]}-#{runner[:dob].to_date.year}").to_s
      end
    end

    threads.each(&:join)

    @result = new_runners

    new_runners.each do |runner|
      Runner.find_or_create_by(checksum: runner[:checksum]) do |run|
        run.runner_name = runner[:runner_name]
        run.surname = runner[:surname]
        run.club_id = 0
        run.category_id = 10
        run.gender = runner[:gender]
        run.dob = runner[:dob]
      end.update(runner.slice(:forest_wre_rang, :sprint_wre_rang, :forest_wre_place, :sprint_wre_place, :wre_id))
    end
    wre_results
    @time = Time.now - time
  end


  def wre_results
    @results_count = 0
    runners = Runner.where.not(wre_id: nil)
    size = (runners.size / 5.0).ceil
    threads = []
    @mutex = Mutex.new
    runners.each_slice(size).to_a.each do |split_runners|
      threads << Thread.new do
        get_results(split_runners)
      end
    end
    @finish  = "true"
  end

  def open_ranking_page(browser, options)
    browser = Watir::Browser.new :chrome
    browser.goto 'http://ranking.orienteering.org/ranking'
    browser.select(id: "FederationRegion").wait_until(&:present?)
    browser.select(id: "FederationRegion").select("MDA")
    browser.select(id: "MainContent_ddlSelectDiscipline").select(option[:type])
    browser.select(id: "MainContent_ddlGroup").select(option[:gender])
    sleep 0.5
    browser.button(id: "MainContent_btnShowRanking").click
    browser.span(class: "flag-MDA").wait_until(&:present?)
  end

  private

  def persons(browser, gender,  type)
    browser.table(class: ["table-responsive", "ranktable"]).trs.drop(1).map do |tr|
      link = tr.link(href: /PersonView/)

      hash = {
        surname: link.text.split.first,
        runner_name:    link.text.split.last,
        wre_id:      link.href[/\d+/].to_i,
        gender:  gender,
        club_id: 0,
        category_id: 10
      }

      if type == "forest"
        {
          forest_wre_rang: tr.td(class: "rankpoint").text,
          forest_wre_place: tr.td.text.scan(/\((.*?)\)/).flatten.first
        }
      else
        {
          sprint_wre_rang: tr.td(class: "rankpoint").text,
          sprint_wre_place: tr.td.text.scan(/\((.*?)\)/).flatten.first
        }
      end.merge(hash)
    end
  end

  def get_results(runners)
    runners.each do |runner|
      ["F", "FS"].each do |distance_type|
        json = JSON.parse(RestClient.get("https://ranking.orienteering.org/api/person/#{runner.wre_id}/results/#{distance_type}").body)
        parse_results_json(json, runner)
      end

      update_ranking(runner)
    end
  end

  def parse_results_json(json, runner)
    json.each do |result|
      @mutex.synchronize do
        competition = Competition.find_or_create_by!(wre_id: result["raceId"]) do |comp|
          comp.date             = result["raceDate"].to_date.as_json
          comp.competition_name = result["raceName"]
          comp.wre_id           = result["raceId"]
          comp.distance_type    = result["raceFormat"]
        end

        group = Group.find_or_create_by(competition: competition, group_name: "#{runner.gender.upcase.sub("F", "W")}21E")

        category_id = case result["points"].to_i
        when 700..999   then 3
        when 1000..1299 then 2
        when 1300..1500 then 1
        else 10
        end

        next if Result.find_by(runner: runner, group: group)

        time  = result["result"].split(":")
        result_data = {
          group: group,
          runner: runner,
          place: result["rank"].to_i,
          time: time.first.to_i * 60 + time.last.to_i,
          category_id: category_id,
          wre_points: result["points"].to_i
        }
        Result.create(result_data)
      end
    end
  end

  def update_ranking(runner)
    json = JSON.parse(RestClient.get("https://ranking.orienteering.org/api/person/#{runner.wre_id}/rankings").body)
    sprint_rank = json["ranks"].detect { |rank| rank["discipline"] == "FS" }
    forest_rank = json["ranks"].detect { |rank| rank["discipline"] == "F" }

    data = {
      forest_wre_rang: forest_rank["points"].to_i,
      forest_wre_place: forest_rank["pos"].to_i,
      sprint_wre_rang: sprint_rank["points"].to_i,
      sprint_wre_place: sprint_rank["pos"].to_i,
    }

    runner.update(data)

  end

  def parse_headers(row)
    headers = {}
    row.each_with_index do |cell, index|
      key = case cell
      when "IOF ID"       then :wre_id
      when "First Name"   then :surname
      when "Last Name"    then :runner_name
      when "WRS Position" then :wre_place
      when "WRS points"   then :wre_rang
      else next
      end
      headers[key] = index
    end
    headers
  end

  def persons_csv(option, gender)
    url = "https://ranking.orienteering.org/download.ashx?doctype=rankfile&rank=#{option[:type]}&group=#{option[:gender]}&todate=2023-03-17&ioc=MDA"

    csv_data      = URI.open(url).read
    csv           = Roo::CSV.new(StringIO.new(csv_data), csv_options: { col_sep: ';' })
    headers_index = parse_headers(csv.first)

    csv.drop(1).map do |row|
      hash = {
        surname:     row[headers_index[:surname]],
        runner_name: row[headers_index[:runner_name]],
        wre_id:      row[headers_index[:wre_id]].to_i,
        gender:      gender,
        club_id:     0,
        category_id: 10
      }

      if option[:type] == "F"
        {
          forest_wre_rang:  row[headers_index[:wre_place]],
          forest_wre_place: row[headers_index[:wre_place]]
        }
      else
        {
          sprint_wre_rang:  row[headers_index[:wre_place]],
          sprint_wre_place: row[headers_index[:wre_place]]
        }
      end.merge(hash)
    end
  end
end
