class Project < ActiveRecord::Base
  belongs_to :user

  validates :title, :user, presence: true

  before_save :capitalize_title

  private

    def capitalize_title
      self.title.capitalize!
    end

end
