class ParserController < ApplicationController
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
        # runner[:checksum] = (Digest::SHA2.new << "#{runner[:runner_name]}-#{runner[:surname]}-#{runner[:dob].to_date.year}").to_s
      end
    end

    threads.each(&:join)

    @result = new_runners

    new_runners.each do |runner|
      Runner.get_runner(runner).update(runner.slice(:forest_wre_rang, :sprint_wre_rang, :forest_wre_place, :sprint_wre_place, :wre_id))
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

  def html_results
    return unless params["file"]

    file = File.read(params["file"])
    html = Nokogiri::HTML(file)
    parse_html(html)

  end

  def fos_results
    browser = Watir::Browser.new
    browser.goto("http://orienteering.md/wp-login.php")

    browser.text_field(id: "user_login").wait_until(&:present?)
    browser.text_field(id: "user_login").set("Hawell")
    browser.text_field(id: "user_pass").set("Sport5Roma")
    browser.button(id: "wp-submit").click
    Watir::Wait.until { browser.url == 'http://orienteering.md/wp-admin/' }

    url = "http://orienteering.md/categorii-sportive/?sort=id"
    browser.goto(url)
    Watir::Wait.until { browser.ready_state == 'complete' }

    response = Nokogiri::HTML(browser.table.html)

    headers_index = parse_headers_fos(response.at_css("thead").css("td").map(&:text))

    response.at_css("tbody").css("tr").each do |runner_data|
      name = runner_data.css("td")[headers_index[:name]].text.split
      data = {
        id: runner_data.css("td")[headers_index[:id]].text.to_i,
        runner_name: name.first,
        surname:     name.last,
        dob:         "#{runner_data.css("td")[headers_index[:dob]].text}-01-01",
        club_id:     0,
        category_id: 10,
        gender:      detect_gender(name.last)
      }
      runner = Runner.get_runner(data).tap do |runner|
        category_id = Category.find_by(category_name: update_category( runner_data.css("td")[headers_index[:current_category]].text)).id
        next if category_id == 10
        category_valid = runner_data.css("td")[headers_index[:category_valid]].text&.to_date&.as_json
        best_category_id = Category.find_by(category_name: update_category( runner_data.css("td")[headers_index[:best_category]].text)).id
        hash = {}
        if !runner.category_id || runner.category_id > category_id
          Result.create(
            runner: runner,
            group_id: 0,
            date: (category_valid.to_date - 3.years).as_json,
            category_id: category_id
          )

          hash.merge!({
              category_id: category_id,
              category_valid: category_valid
          })
        elsif runner.category_id == category_id && (!runner.category_valid || runner.category_valid.to_date < category_valid.to_date)
          Result.create(
            runner: runner,
            group_id: 0,
            date: (category_valid.to_date - 3.years).as_json,
            category_id: category_id
          )
          hash.merge!({ category_valid: category_valid })
        end

        if !runner.best_category_id || runner.best_category_id > best_category_id
          hash.merge!({ best_category_id: best_category_id })
        end

        runner.update!(hash)
      end
    rescue
      byebug
    end
  ensure
    browser.close
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
      forest_wre_rang: forest_rank&.fetch("points")&.to_i,
      forest_wre_place: forest_rank&.fetch("pos")&.to_i,
      sprint_wre_rang: sprint_rank&.fetch("points")&.to_i,
      sprint_wre_place: sprint_rank&.fetch("pos")&.to_i,
    }
    @mutex.synchronize do
      runner.update(data)
    end
  end

  def parse_headers_csv(row)
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
    headers_index = parse_headers_csv(csv.first)

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

   def parse_html(html)
    data = {}
    trs = html.css("tr").reject { |tr| tr.text.blank? }
    groups = trs.slice_before { |tr| tr.text.include?('Categoria de v') }.to_a
    competition_data = groups.shift

    index = competition_data.find_index { |td| td.text[/PROCES VERBAL/i]}

    headers = trs.detect { |tr| tr.text.match?(/Nume(,|) prenume/i) }.css("td").map(&:text)
    headers_index = parse_headers(headers)


    data[:competition_name] = competition_data[index - 1].text.strip
    data[:distance_type] = convert_distance_type(competition_data[index + 1].text.strip)
    data[:date] = Date.parse(competition_data.detect { |d| Date.parse(d.text) rescue false }.text).as_json

    data[:groups] = groups.map do |group|
      group_name = group.detect {|tr| tr.text[/Categoria de v/]}.css("td:not(:empty)")[1].text
      group_data = {group_name: group_name}
      if clasa_tr = group.detect { |tr| tr.text[/Clasadistanței/]}
        tds = clasa_tr.css("td:not(:empty)")
        tds_index = tds.find_index { |td| td.text[/Clasadistanței/]}
        group_data[:clasa] = tds[tds_index + 1].text
      end

      header_index = group.find_index { |tr| tr.css("td").map(&:text) == headers }


      string_data = if  group[header_index+1].css("td").any? {|td| td["rowspan"] }
        group[3..-1].each_slice(2).to_a.select {|tr| tr.first.at_css("td").text.to_i > 0 }.map do |array_data|
          first_array = array_data.first.css("td").chunk_while { |a, b| a["colspan"].nil? && b["colspan"].nil? }.flat_map { |chunk| chunk.length >= 2 ? [nil] : chunk }
          second_array = array_data.second.css("td").chunk_while { |a, b| a["colspan"].nil? && b["colspan"].nil? }.flat_map { |chunk| chunk.length >= 2 ? [nil] : chunk }
          arr = 1
          new_arr = []

          until first_array.empty? && second_array.empty?
            if arr == 1
              if !first_array.first.nil?
                new_arr << first_array.shift
              else
                arr = 2
                first_array.shift
              end
            else
               if !second_array.first.nil?
                new_arr << second_array.shift
              else
                arr = 1
                second_array.shift
              end
            end
          end
          new_arr.map(&:text)
        end
      else
        group[3..-1].select {|tr| tr.at_css("td").text.to_i > 0 }.map{ |tr| tr.css("td").map(&:text) }
      end

      group_data[:results] = string_data.map do |result|
        place = result[headers_index[:place]].to_i
        dob = if headers_index[:dob]
          result[headers_index[:dob]]
        else
          result.detect { |d| d[/\d{2}\.\d{2}\.\d{4}/] rescue false} || Time.now
        end.to_date.as_json
        next if place < 1

        {
        runner: {
          runner_name: result[headers_index[:name]].split.first,
          surname: result[headers_index[:name]].split.last,
          dob: dob,
          club: result[headers_index[:club]],
          category_id: Category.find_by(category_name: update_category(result[headers_index[:current_category]]))&.id || 10
        },
        result: {
          place: place,
          time:  convert_time(result[headers_index[:result]])
        }
      }
      end.reject(&:nil?)
      group_data
    end
    @data = data
    parse_data(data)
  end

  def parse_headers(row)
    headers = {}
    row.each_with_index do |cell, index|
      key = case cell
      when /Clasament/i            then :place
      when /Nume(,)? prenume/i     then :name
      when /Result|Rezultat/i      then :result
      when /Echipa/i               then :club
      when /Kval|Cat.sport.$/i     then :current_category
      when /Data(| )na(s|ș)terii/i then :dob
      else next
      end
      # when "IOF ID"       then :wre_id
      # when "First Name"   then :surname
      # when "Last Name"    then :runner_name
      # when "WRS Position" then :wre_place
      # when "WRS points"   then :wre_rang
      # else next
      # end
      headers[key] = index
    end
    headers
  end

  def update_category(category)
    category.gsub("І", "I").gsub("-u", " j").gsub("Ij", "I j").gsub("BR", "f/c").gsub(/KMS|CMS/, "CMSRM").gsub(/MS$/, "MSRM").gsub("MIS", "MISRM")
  end

  def parse_data(data)
    checksum = (Digest::SHA2.new << "#{data[:competition_name]}-#{data[:date]}-#{data[:distance_type]}").to_s

    competition = Competition.find_or_create_by(checksum: checksum) do |comp|
      comp.competition_name = data[:competition_name]
      comp.date = data[:date]
      comp.distance_type = data[:distance_type]
    end

    data[:groups].each do |group_data|
      group = Group.find_or_create_by(competition: competition, group_name: group_data[:group_name])
      group_data[:results].each do |result|
        runner = result[:runner]
        runner[:checksum] = (Digest::SHA2.new << "#{runner[:runner_name]}-#{runner[:surname]}-#{runner[:dob].to_date.year}").to_s
        runner[:gender] = group.group_name[/^(F|W)/] ? "F" : "M"
        runner_id = Runner.find_or_create_by!(checksum: runner[:checksum]) do |run|
          run.runner_name = runner[:runner_name]
          run.surname = runner[:surname]
          run.club_id = 0
          run.category_id = runner[:category_id]
          run.gender = runner[:gender]
          run.dob = runner[:dob]
        end.id


        next if Result.find_by(runner_id: runner_id, group: group)

        result_data = {
          group: group,
          runner_id: runner_id,
          place: result[:result][:place],
          time: result[:result][:time],
          category_id: 10
        }
        Result.create(result_data)

      end
    end
  end

  def convert_distance_type(string)
    case string
    when /sprint/i          then "Sprint"
    when /long/i, /lung/i   then "Lunga"
    when /middle/i, /medie/ then "Medie"
    else string
    end
  end

  def convert_time(string)
    hours            = string.split(":").first.to_i
    minutes, seconds = string.split(":").last.split(".").map(&:to_i)

    hours * 3600 + minutes * 60 + seconds
  end

   def parse_headers_fos(row)
    headers = {}
    row.each_with_index do |cell, index|
      key = case cell
      when /FOS ID/i            then :id
      when /Nume, Prenume/i     then :name
      when /Anul nașterii/i      then :dob
      when /Club/i               then :club
      when /Cat. Sportivă Curent/i     then :current_category
      when /Expiră/i then :category_valid
      when /Cat. maximă/i then :best_category
      else next
      end

      headers[key] = index
    end
    headers
  end

  def detect_gender(string)
    case string
    when "Nichita", "Ilia", "Mircea" then "M"
    when "Irene", /a$/i then "F"
    else "M"
    end
  end
end
