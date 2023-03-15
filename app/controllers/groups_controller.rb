class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy]

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
