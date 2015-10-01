class ProjectsController < ApplicationController
  load_and_authorize_resource through: :current_user

  def index
  end

  def create
    @project.save!
    render :show
  end

  def update
    @project.update!(project_params)
    render :show
  end

  def destroy
    @project.destroy!
    render :show
  end

  private

  def project_params
    params.require(:project).permit(:title)
  end
end