class CommentsController < ApplicationController
  load_and_authorize_resource :task, only: %i(create index)
  load_and_authorize_resource through: :task, only: %i(create index)

  load_and_authorize_resource except: %i(create index)

  def index
  end

  def create
    @comment.save!
  end

  def update
    @comment.update!(comment_params)
  end

  def destroy
    @comment.destroy!
  end

  private

  def comment_params
    params.require(:comment).permit(:note, attachments_attributes: [:file])
  end
end