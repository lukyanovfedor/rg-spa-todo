class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i(create index)
  load_and_authorize_resource through: :project, only: %i(create index)

  load_and_authorize_resource except: %i(create index)

  def index
  end

  def show
  end

  def create
    @task.save!
    render :show
  end

  def update
    @task.update!(task_params)
    render :show
  end

  def destroy
    @task.destroy!
    render :show
  end

  def toggle
    @task.toggle!
    render :show
  end

  private

  def task_params
    params.require(:task).permit(:title, :state, :deadline, :position)
  end
end