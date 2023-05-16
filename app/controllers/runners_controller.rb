class RunnersController < ApplicationController
  before_action :set_runner, only: %i[ show edit update destroy ]

  # GET /runners or /runners.json
  def index
    if params[:category]
       @runners = Runner.all.all.where(category_id: params[:category])
     else
      @runners = Runner.all
    end

    @runners = case params[:sort]
    when "runner"
      @runners.sort_by { |runner| "#{runner.runner_name} #{runner.surname}" }
    else
      @runners.order("#{params[:sort]}")
    end
  end

  def compare
    show_wins(params[:first_name], params[:second_name]) if params[:first_name] && params[:second_name]
  end

  # GET /runners/1 or /runners/1.json
  def show
  end

  # GET /runners/new
  def new
    @runner = Runner.new
  end

  # GET /runners/1/edit
  def edit
  end

  # POST /runners or /runners.json
  def create
    params = runner_params
    competition_params = params.dig("results_attributes", "group_attributes", "competition_attributes")
    group_params = params.dig("results_attributes", "group_attributes").except("competition_attributes")

    if competition_params
      group_params[:competition_id] = Competition.create!(competition_params).id
    end


    group_params = params.dig("results_attributes", "group_attributes").except("competition_attributes")

    if group_params[:group_name]

    end


    if params["results_attributes"]
      result_params = params["results_attributes"].except("group_attributes")

      params[:category_valid] = if result_params['date(2i)']
        ("#{result_params['date(1i)']}-#{result_params['date(2i)']}-#{result_params['date(3i)']}".to_date + 2.years).as_json
      else
         (Competition.find(params.dig("results_attributes", "group_attributes", "competition_id")).date + 2.years).as_json
      end
    end

    @runner = Runner.new(params.except("results_attributes"))


    return
    result_params[:runner_id] = @runner.id

    Result.create!(result_params.except("group_attributes"))


    respond_to do |format|
      format.html { redirect_to runner_url(@runner), notice: "Runner was successfully created." }
      format.json { render :show, status: :created, location: @runner }
    end
  rescue
    respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /runners/1 or /runners/1.json
  def update
    respond_to do |format|
      if @runner.update(runner_params)
        format.html { redirect_to runner_url(@runner), notice: "Runner was successfully updated." }
        format.json { render :show, status: :ok, location: @runner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runners/1 or /runners/1.json
  def destroy
    @runner.destroy

    respond_to do |format|
      format.html { redirect_to runners_url, notice: "Runner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def test_modal
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_runner
      @runner = Runner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def runner_params
      params.require(:runner).permit(:id, :runner_name, :surname, :dob, :club_id, :gender, :wre_id, :best_category_id, :category_id, :category_valid, :sprint_wre_rang, :sprint_wre_place, :forest_wre_place, :forest_wre_rang, :checksum, results_attributes:[:date, :place, :time, :group_id , :wre_points,group_attributes: [:id, :group_name, :competition_id, competition_attributes: [:id, :competition_name, :date, :location, :country, :distance_type, :wre_id]]])
    end

  def show_wins(one, two)
    @runner_one = Runner.find(one)
    @runner_two = Runner.find(two)
    # @index_array1 = result_index_array(@runner_one.results)
    # @index_array2 = result_index_array(@runner_two.results)

    @runner_one_wins = 0
    @runner_two_wins = 0
    @ties            = 0

    group_ids_one = @runner_one.results.pluck(:group_id)
    group_ids_two = @runner_two.results.pluck(:group_id)
    @common_group = (group_ids_one & group_ids_two)

    @common_group.each do |group|
      first_runner_place  = Result.find_by(group_id: group, runner: @runner_one).place
      second_runner_place = Result.find_by(group_id: group, runner: @runner_two).place

      first_runner_place  = 9999999 if first_runner_place.zero?
      second_runner_place = 9999999 if second_runner_place.zero?

      if first_runner_place == second_runner_place
        @ties += 1
      elsif first_runner_place < second_runner_place
        @runner_one_wins += 1
      else
        @runner_two_wins += 1
      end
    end
  end
end
