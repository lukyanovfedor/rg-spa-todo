class Comment < ActiveRecord::Base
  belongs_to :task

  mount_uploaders :files, CommentFileUploader
end
