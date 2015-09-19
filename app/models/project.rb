class Project < ActiveRecord::Base

  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :title, :user, presence: true

  before_save :capitalize_title

  private

    def capitalize_title
      self.title.capitalize!
    end

end
