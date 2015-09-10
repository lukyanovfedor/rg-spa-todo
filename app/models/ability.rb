class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :read, :update, :destroy, to: :rud

    if user
      can :create, Project
      can :rud, Project, user_id: user.id
    end
  end
end