class Project < ActiveRecord::Base
  belongs_to :user

  has_many :tasks, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :user, presence: true

  before_save :capitalize_title

  private

  def capitalize_title
    self.title.capitalize!
  end
end
