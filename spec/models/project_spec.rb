require 'rails_helper'

RSpec.describe Project, type: :model do
  subject(:project) { FactoryGirl.create(:project) }

  describe 'Associations' do
    it { expect(project).to have_many(:tasks).dependent(:destroy) }
    it { expect(project).to belong_to(:user) }
  end

  describe 'Validations' do
    it { expect(project).to validate_presence_of(:user) }
    it { expect(project).to validate_presence_of(:title) }
  end
end
