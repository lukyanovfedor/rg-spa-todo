class ProjectsController < ApplicationController

  load_and_authorize_resource through: :current_user

  def index
  end

  def create
    if @project.save
    else
    end
  end

  def update
    if @project.update(project_params)
    else
    end
  end

  def show
  end

  def destroy
    if @project.destroy
    else
    end
  end

  private

    def project_params
      params.require(:project).permit(:title)
    end

end