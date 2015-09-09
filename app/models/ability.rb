class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :create, Project
      can %i(read update destroy), Project, user_id: user.id
    end
  end
end