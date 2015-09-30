class Comment < ActiveRecord::Base
  belongs_to :task

  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments

  validates :note, :task, presence: true
end
