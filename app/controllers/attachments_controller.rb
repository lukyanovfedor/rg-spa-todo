class AttachmentsController < ApplicationController
  load_and_authorize_resource

  def destroy
    @attachment.destroy!
  end
end