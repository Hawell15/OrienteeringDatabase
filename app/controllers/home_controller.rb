class HomeController < ApplicationController
  def index

  end

  def get_groups
    @group = Group.where(competition_id: params[:comp_id])
    render json: @group
  end
end
