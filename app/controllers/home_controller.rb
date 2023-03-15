class HomeController < ApplicationController
  def index
  end

  def get_groups
    @group = Group.where(competition_id: params[:comp_id])
    render json: @group
  end


  def wre_id
    browser = Watir::Browser.new :chrome
    browser.goto 'http://ranking.orienteering.org/ranking'
    browser.select(id: "FederationRegion").wait_until(&:present?)
    browser.select(id: "FederationRegion").select("MDA")
    sleep 0.5
    browser.button(id: "MainContent_btnShowRanking").click
    browser.span(class: "flag-MDA").wait_until(&:present?)
    ids_forest = persons(browser, "M", "forest")

    browser.select(id: "MainContent_ddlSelectDiscipline").select("FS")
    sleep 0.5
    browser.button(id: "MainContent_btnShowRanking").click
    browser.span(id: "MainContent_RankTableControl", text: /Sprint Orienteering World Ranking List/).wait_until(&:present?)
    ids_sprint = persons(browser, "M", "sprint")
    @ids = (ids_forest + ids_sprint).group_by { |h| h[:wre_id] }.map do |_, hashes|
      hashes.reduce { |merged_hash, hash| merged_hash.merge(hash) }
    end

    browser.select(id: "MainContent_ddlGroup").select("Women")
    sleep 0.5
    browser.select(id: "MainContent_ddlSelectDiscipline").select("F")
    sleep 0.5
    browser.button(id: "MainContent_btnShowRanking").click
    browser.select(id: "MainContent_ddlGroup").wait_until { |val| val.value == "WOMEN"}
    ids_forest = persons(browser, "F", "forest")
    browser.select(id: "MainContent_ddlSelectDiscipline").select("FS")
    sleep 0.5
    browser.button(id: "MainContent_btnShowRanking").click
    browser.span(id: "MainContent_RankTableControl", text: /Sprint Orienteering World Ranking List/).wait_until(&:present?)
    ids_sprint = persons(browser, "F", "sprint")

    @ids += (ids_forest + ids_sprint).group_by { |h| h[:wre_id] }.map do |_, hashes|
      hashes.reduce { |merged_hash, hash| merged_hash.merge(hash) }
    end

    @ids.each do |runner|
      if run = Runner.find_by(wre_id: runner[:wre_id])
        run.forrest_wre_rang = runner[:forrest_wre_rang]
        run.sprint_wre_rang = runner[:sprint_wre_rang]
        run.save!
      else
        url = "https://eventor.orienteering.org/Athletes/Details/#{runner[:wre_id]}"
        response = Nokogiri::HTML(RestClient.get(url).body)
        runner[:dob] = "#{response.at_css("tr:contains('Year of birth') td.athleteFactsInfo").text}-01-01"
        checksum = (Digest::SHA2.new << "#{runner[:runner_name]}-#{runner[:surname]}-#{runner[:dob].to_date.year}").to_s
        if run = Runner.find_by(checksum: checksum)
          run.wre_id           = runner[:wre_id]
          run.forrest_wre_rang = runner[:forrest_wre_rang]
          run.sprint_wre_rang  = runner[:sprint_wre_rang]
          run.save!
        else
          Runner.create(runner)
        end
      end
    end
  ensure
    browser.close if browser
  end

  def wre_results_men
    @results_count = 0
    runners = Runner.where(gender: "M").where.not(wre_id: nil)
    get_results(runners)
    render json: { competitions: @results_count}
  end

  private

  def persons(browser, gender,  type)
    browser.table(class: "table-responsive ranktable").trs.drop(1).map do |tr|
      link = tr.link(href: /PersonView/)

      hash = {
        surname: link.text.split.first,
        runner_name:    link.text.split.last,
        wre_id:      link.href[/\d+/],
        gender:  gender,
        club_id: 1,
        category_id: 10
      }

      if type == "forest"
        {
          forrest_wre_rang: tr.td.text.scan(/\((.*?)\)/).flatten.first,
          # forest_wre_place: tr.td(class: "rankpoint").text
        }
      else
        {
          sprint_wre_rang: tr.td.text.scan(/\((.*?)\)/).flatten.first,
          # sprint_wre_place: tr.td(class: "rankpoint").text
        }
      end.merge(hash)
    end
  end

  def get_results(runners)
    browser = Watir::Browser.new :chrome
    runners.each do |runner|
      browser.goto "https://ranking.orienteering.org/PersonView?person=#{runner[:wre_id]}"
      browser.table(class: "ranktable").wait_until(&:present?)
      html = Nokogiri::HTML(browser.html)

      parse_results(html, runner)

      return unless browser.link(href: "#list", text: /Sprint/).present?

      browser.link(href: "#list", text: /Sprint/).click
      browser.table(class: "ranktable", text:/Sprint/).wait_until(&:present?)
      html = Nokogiri::HTML(browser.html)
      parse_results(html, runner, "Sprint")
    end
  ensure
    browser.close
  end


  def parse_results(html, runner, distance_type = nil)
    html.at_css("table.ranktable").css("tr").drop(1).each do |tr|
      wre_id = tr.css("td")[1].at_css("a")["href"][/event=\d+/][/\d+/]

      competition = Competition.find_or_create_by!(wre_id: wre_id) do |comp|
        comp.date             = Date.strptime(tr.at_css("td").text, '%d/%m/%Y')
        comp.competition_name = tr.css("td")[1].text
        comp.wre_id           = tr.css("td")[1].at_css("a")["href"][/event=\d+/][/\d+/]
        comp.distance_type    = distance_type
        comp.distance_type  ||= case comp.competition_name
        when /Long/i then "Long"
        when /Middle/i then "Middle"
        end
      end

      category_id = case tr.css("td")[-2].text.to_i
      when 700..999   then 3
      when 1000..1299 then 2
      when 1300..1500 then 1
      else 10
      end

      group = Group.find_or_create_by(competition: competition, group_name: "#{runner.gender.upcase.sub("F", "W")}21E")
      next if Result.find_by(runner: runner, group: group)
      time  =tr.css("td")[4].text.split(":")
      result_data = {
        group: group,
        runner: runner,
        place: tr.css("td")[3].text.to_i,
        time: time.first.to_i * 60 + time.last.to_i,
        category_id: category_id,
        wre_points: tr.css("td")[-2].text.to_i
      }
      Result.create(result_data)
    end
  end
end
