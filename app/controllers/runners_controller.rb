class RunnersController < ApplicationController
  before_action :set_runner, only: %i[ show edit update destroy ]

  # GET /runners or /runners.json
  def index
    @runners = Runner.all
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
    @runner = Runner.new(runner_params)

    respond_to do |format|
      if @runner.save
        format.html { redirect_to runner_url(@runner), notice: "Runner was successfully created." }
        format.json { render :show, status: :created, location: @runner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @runner.errors, status: :unprocessable_entity }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_runner
      @runner = Runner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def runner_params
      params.require(:runner).permit(:runner_name, :surname, :dob, :club, :gender, :wre_id, :best_category, :category, :category_valid, :sprint_wre_rang, :forrest_wre_rang, :checksum)
    end
end
