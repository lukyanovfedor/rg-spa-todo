class Task < ActiveRecord::Base
  include AASM

  belongs_to :project

  has_many :comments

  STATES = %i(in_progress finished)

  aasm column: :state, whiny_transitions: false  do
    state :in_progress, initial: true
    state :finished

    event :in_work do
      transitions from: :finished, to: :in_progress
    end

    event :done do
      transitions from: :in_progress, to: :finished
    end
  end

  def toggle
    if in_progress?
      done!
    else
      in_work!
    end
  end
end
