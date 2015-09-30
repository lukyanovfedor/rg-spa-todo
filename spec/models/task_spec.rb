require 'rails_helper'

RSpec.describe Task, type: :model do
  subject(:task) { FactoryGirl.create(:task) }

  describe 'Associations' do
    it { expect(task).to have_many(:comments).dependent(:destroy) }
    it { expect(task).to belong_to(:project) }
  end

  describe 'Validations' do
    it { expect(task).to validate_presence_of(:title) }
    it { expect(task).to validate_presence_of(:project) }
  end

  describe 'States' do
    it 'expect in_progress to be initial state' do
      expect(task.state).to eq('in_progress')
    end

    describe 'done' do
      it 'expect to allow transition from in_progress to finished' do
        task.done
        expect(task.state).to eq('finished')
      end
    end

    describe 'in_work' do
      it 'expect to allow transition from finished to in_progress' do
        task.done
        task.in_work
        expect(task.state).to eq('in_progress')
      end
    end
  end

  describe '#toggle' do
    context 'state is in_progress' do
      it 'expect to change state to finished' do
        task.toggle!
        expect(task.state).to eq('finished')
      end
    end

    context 'state is finished' do
      it 'expect to change state to finished' do
        task.done
        task.toggle!
        expect(task.state).to eq('in_progress')
      end
    end
  end
end
