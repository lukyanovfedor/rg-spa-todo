class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i(create index)
  load_and_authorize_resource through: :project, only: %i(create index)

  load_and_authorize_resource except: %i(create index)

  def index
  end

  def show
  end

  def create
    if @task.save
    else
    end
  end

  def update
    if @task.update(task_params)
    else
    end
  end

  def destroy
    if @task.destroy
    else
    end
  end

  def toggle
    if @task.toggle
    else
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :state, :deadline)
  end
end