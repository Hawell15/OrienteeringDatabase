class HomeController < ApplicationController
  def index
    @clubs_count        = Club.count
    @runners_count      = Runner.count
    @competitions_count = Competition.count
    @results_count      = Result.count

    @competitions = Competition.order(date: :desc).limit(10)
  end

  def aaa

  end

  def get_groups
  end
  def suggestions
    @runners = Runner.where("runner_name LIKE ?", "%#{params[:query]}%").limit(3)
    render json: @runners.map { |runner| { name: "#{runner.runner_name} #{runner.surname}", id: runner.id } }
  end

  private
end
