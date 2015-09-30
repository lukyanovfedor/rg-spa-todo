class Attachment < ActiveRecord::Base
  belongs_to :comment

  mount_uploader :file, AttachmentUploader

  validates :file, presence: true
end
