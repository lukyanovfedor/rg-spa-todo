class ProjectsController < ApplicationController
  load_and_authorize_resource through: :current_user

  def index
  end

  def create
    @project.save!
  end

  def update
    @project.update!(project_params)
  end

  def show
  end

  def destroy
    @project.destroy!
  end

  private

  def project_params
    params.require(:project).permit(:title)
  end
end