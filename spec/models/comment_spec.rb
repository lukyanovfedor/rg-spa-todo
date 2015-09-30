require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { FactoryGirl.create(:comment) }

  describe 'Associations' do
    it { expect(comment).to belong_to(:task) }
    it { expect(comment).to have_many(:attachments).dependent(:destroy) }
  end

  describe 'Nested attributes' do
    it { expect(comment).to accept_nested_attributes_for(:attachments) }
  end

  describe 'Validation' do
    it { expect(comment).to validate_presence_of(:note) }
    it { expect(comment).to validate_presence_of(:task) }
  end
end
