def create_ability
  ability = Object.new.extend(CanCan::Ability)
  allow(controller).to receive(:current_ability).and_return(ability)
  ability
end