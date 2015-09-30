require 'rails_helper'

RSpec.describe Attachment, type: :model do
  subject(:attachment) { FactoryGirl.create(:attachment) }

  describe 'Associations' do
    it { expect(attachment).to belong_to(:comment) }
  end

  describe 'Validation' do
    it { expect(attachment).to validate_presence_of(:file) }
  end
end
