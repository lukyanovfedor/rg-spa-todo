class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :read, :update, :destroy, to: :rud

    if user
      can :create, Project
      can %i(read update destroy), Project, user_id: user.id
      can :manage, Task, project: { user_id: user.id }
      can :manage, Comment, task: { project: { user_id: user.id } }
    end
  end
end