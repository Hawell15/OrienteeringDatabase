class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy count_rang]

  # GET /groups or /groups.json
  def index
    @groups = if params[:comp_id]
      Group.where(competition_id: params[:comp_id])
    else
      Group.all
    end

    @groups = case params[:sort]
    when  "competition_name", "date"
      @groups.sort_by {|group| group.competition.send(params[:sort]) }
    else
      @groups.order("#{params[:sort]}")
    end
  end

  # GET /groups/1 or /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def count_rang
    runner_ids = @group.results.order(:place).limit(12).pluck(:runner_id)
    range      = Runner.joins(:category).where(id: runner_ids).sum('categories.points')
    @group.update!(rang: rang)

    winner_time = @group.results.order(:place).first.time
    clasa       = @group.clasa

    percent_hash = get_rang_percents(rang).map do |k, v|
      case clasa
      when "MSRM", "CMSRM", "Seniori"
        [k, v] if [4, 5, 6].include?(k)
      when "Juniori"
        [k, v] if [7, 8, 9].include?(k)
      end
    end.compact.to_h


    time_hash = percent_hash.transform_values { |v| v * winner_time / 100 }


    @group.results.each do |res|
      time = res.time
      place =  res.place

      category_id = if clasa == "MSRM" && place == 1
        2
      elsif clasa[/MSRM/] &&(1..3).include?(place)
        3
      else
        time_hash.detect  { |k,v| v >= time }&.first || 10
      end

       res.update!(category_id: category_id)

      next unless res.runner.category_id > category_id

      res.runner.update!(
        category_id:      category_id,
        category_valid:   (res.date + 2.years).as_json,
        best_category_id: [category_id, res.runner.best_category_id].min
      )
    end

    redirect_to group_path(@group.id)
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    byebug
   # competition_id = group_params["competition_id"].presence ||  Competition.create(group_params["competition_attributes"]).id

    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to group_url(@group), notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_url(@group), notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def get_competitions

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:group_name, :competition_id, :rang, :clasa,
      competition_attributes: [:id, :competition_name, :date, :location, :country, :distance_type, :wre_id])
    end
end
