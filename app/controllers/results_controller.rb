class ResultsController < ApplicationController
  before_action :set_result, only: %i[ show edit update destroy ]

  # GET /results or /results.json
  def index
     @results = case params[:sort]
      when "runner"
      Result.all.sort_by { |result| "#{result.runner.runner_name} #{result.runner.surname}" }
    when "competition"
       Result.all.sort_by { |result| "#{result.group.competition.competition_name} #{result.group.competition.date.year}" }
     when "group"
            Result.all.sort_by { |result| result.group.group_name }
    else
      Result.order("#{params[:sort]}")
    end

    # @results = Result.all
  end

  # GET /results/1 or /results/1.json
  def show
  end

  # GET /results/new
  def new
    @result = Result.new
  end

  # GET /results/1/edit
  def edit
  end

  # POST /results or /results.json
  def create
    if result_params.dig("group_attributes", "group_name")
      @result = Result.new(result_params)
    else
      @result = Result.new(result_params.except(:group_attributes))
    end

    respond_to do |format|
      if @result.save
        format.html { redirect_to result_url(@result), notice: "Result was successfully created." }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results/1 or /results/1.json
  def update
    params = result_params
    params["group_attributes"][:competition_id] = params["group_attributes"]["competition_id"].presence || Competition.create(params["group_attributes"]["competition_attributes"]).id
    params[:group_id] ||= Group.create!(result_params["group_attributes"].except("competition_id")).id

    respond_to do |format|
      if @result.update(params.except("group_attributes"))
        format.html { redirect_to result_url(@result), notice: "Result was successfully updated." }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1 or /results/1.json
  def destroy
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url, notice: "Result was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_result
      @result = Result.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def result_params
      params.require(:result).permit(:place, :runner_id, :time, :category_id, :group_id, :wre_points, group_attributes: [:id, :group_name, :competition_id, competition_attributes: [:id, :competition_name, :date, :location, :country, :distance_type, :wre_id]])
    end
end
