class CommentsController < ApplicationController
  load_and_authorize_resource :task, only: %i(create index)
  load_and_authorize_resource through: :task, only: %i(create index)

  load_and_authorize_resource except: %i(create index)

  def index
  end

  def show
  end

  def create
    if @comment.save
    else
    end
  end

  def update
    if @comment.update(comment_params)
    else
    end
  end

  def destroy
    if @comment.destroy
    else
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:note, {files: []})
  end
end