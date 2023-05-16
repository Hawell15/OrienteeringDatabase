class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
     @categories = if params[:sort] == "count_runners"
      Category.all.sort_by {|category| category.runners.count }
    else
      Category.order("#{params[:sort]}")
    end
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to category_url(@category), notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to category_url(@category), notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_url, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def count_categories
    @updated_runners = Runner.where('category_valid < ?', Date.today) || []
    @updated_runners.each do |runner|
      next if runner.category_id == 10
      category_valid = "2100-01-01" if runner.category_id == 9
      Result.create(
        runner: runner,
        group_id: 1,
        date: runner.category_valid,
        category_id: runner.category_id + 1
      )
      runner.update!(
        category_id: runner.category_id + 1,
        category_valid: category_valid || runner.category_valid + 2.years
      )
    end

    runner_query = Runner.joins(:results)
             .where("results.date > ?", (Date.today - 2.years).as_json)
             .where("runners.category_id >= results.category_id")
             .where.not("(runners.category_id = results.category_id AND runners.category_valid >= results.date)")
             .select("runners.*, results.category_id as min_category_id, results.date as max_result_date")
             .order("runners.id ASC, results.category_id ASC, results.date DESC")
             .group_by(&:id)
             .map { |id, group| group.first }


    runner_query.each do |runner|
      runner.update!(
        category_id:      runner.min_category_id,
        category_valid:   (runner.max_result_date.to_date + 2.years).as_json,
        best_category_id: [runner.min_category_id, runner.best_category_id].min
      )
    end

    @updated_runners += runner_query
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:category_name, :full_name, :points)
    end
end
