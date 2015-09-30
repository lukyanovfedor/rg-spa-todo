class Task < ActiveRecord::Base
  include AASM

  STATES = %i(in_progress finished)

  belongs_to :project

  has_many :comments, dependent: :destroy

  acts_as_list scope: :project

  validates :title, :project, presence: true

  aasm column: :state do
    state :in_progress, initial: true
    state :finished

    event :in_work do
      transitions from: :finished, to: :in_progress
    end

    event :done do
      transitions from: :in_progress, to: :finished
    end
  end

  def toggle!
    if in_progress?
      done!
    else
      in_work!
    end
  end
end
