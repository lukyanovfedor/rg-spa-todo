require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create(:user) }

  describe 'Validation' do
    it { expect(user).to validate_presence_of(:first_name) }
    it { expect(user).to validate_presence_of(:last_name) }
  end

  describe 'Associations' do
    it { expect(user).to have_many(:projects).dependent(:destroy) }
  end
end
