require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  context 'user exist' do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, user: user) }
    let(:task) { FactoryGirl.create(:task, project: project) }
    let(:comment) { FactoryGirl.create(:comment, task: task) }

    it { expect(ability).to be_able_to(:create, Project) }
    it { expect(ability).to be_able_to(:destroy, Project.new(user: user)) }
    it { expect(ability).to be_able_to(:update, Project.new(user: user)) }
    it { expect(ability).to be_able_to(:read, Project.new(user: user)) }

    it { expect(ability).not_to be_able_to(:destroy, Project.new) }
    it { expect(ability).not_to be_able_to(:update, Project.new) }
    it { expect(ability).not_to be_able_to(:read, Project.new) }

    it { expect(ability).to be_able_to(:manage, Task.new(project: project)) }
    it { expect(ability).not_to be_able_to(:manage, Task.new) }

    it { expect(ability).to be_able_to(:manage, Comment.new(task: task)) }
    it { expect(ability).not_to be_able_to(:manage, Comment.new) }

    it { expect(ability).to be_able_to(:manage, Attachment.new(comment: comment)) }
    it { expect(ability).not_to be_able_to(:manage, Attachment.new) }
  end

  context 'user not exist' do
    let(:user) { nil }

    it { expect(ability).not_to be_able_to(:manage, Project) }
    it { expect(ability).not_to be_able_to(:manage, Task) }
    it { expect(ability).not_to be_able_to(:manage, Comment) }
    it { expect(ability).not_to be_able_to(:manage, Attachment) }
  end
end