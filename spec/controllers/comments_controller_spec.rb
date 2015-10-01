require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:project) { FactoryGirl.create(:project, user: user) }
  let!(:task) { FactoryGirl.create(:task, project: project) }
  let!(:comment) { FactoryGirl.create(:comment, task: task) }
  let!(:comment_prms) { FactoryGirl.attributes_for(:comment) }
  let(:ability) { create_ability }

  before do
    ability.can :manage, Task
    allow(Task).to receive(:find) { task }
    allow(controller).to receive(:current_user) { user }
  end

  describe '#index' do
    context 'with ability' do
      before { ability.can :read, Comment }

      it 'expect to render index template' do
        get :index, task_id: task.id.to_s, format: :json
        expect(response).to render_template('index')
      end

      it 'expect to assign @comments' do
        get :index, task_id: task.id.to_s, format: :json
        expect(assigns(:comments)).not_to be_nil
      end
    end

    context 'without abilities' do
      before { ability.cannot :read, Comment }

      it 'expect to raise CanCan::AccessDenied' do
        expect { get :index, task_id: task.id.to_s, format: :json }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#create' do
    context 'with ability' do
      before { ability.can :create, Comment }

      context 'prms valid' do
        before do
          allow(Comment).to receive(:new) { comment }
          allow(comment).to receive(:save!) { true }
        end

        it 'expect to assign @comment' do
          post :create, format: :json, task_id: task.id.to_s, comment: comment_prms
          expect(assigns(:comment)).not_to be_nil
        end

        it 'expect to receive :save!' do
          expect(comment).to receive(:save!)
          post :create, format: :json, task_id: task.id.to_s, comment: comment_prms
        end

        it 'expect to render show template' do
          post :create, format: :json, task_id: task.id.to_s, comment: comment_prms
          expect(response).to render_template('show')
        end
      end

      context 'prms invalid' do
        before { comment_prms[:note] = '' }

        it { expect {post :create, format: :json, task_id: task.id.to_s, comment: comment_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :create, Comment }

      it 'expect to raise CanCan::AccessDenied' do
        expect {post :create, format: :json, task_id: task.id.to_s, comment: comment_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#update' do
    context 'with ability' do
      before { ability.can :update, Comment }

      context 'prms valid' do
        before do
          allow(Comment).to receive(:find) { comment }
          allow(comment).to receive(:update!) { true }
        end

        it 'expect to assign @comment' do
          put :update, id: comment.id.to_s, format: :json, comment: comment_prms
          expect(assigns(:comment)).not_to be_nil
        end

        it 'expect to receive :update!' do
          expect(comment).to receive(:update!)
          put :update, id: comment.id.to_s, format: :json, comment: comment_prms
        end

        it 'expect to render show template' do
          put :update, id: comment.id.to_s, format: :json, comment: comment_prms
          expect(response).to render_template('show')
        end
      end

      context 'prms invalid' do
        before { comment_prms[:note] = '' }

        it { expect {put :update, id: comment.id.to_s, format: :json, comment: comment_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :update, Comment }

      it 'expect to raise CanCan::AccessDenied' do
        expect {put :update, id: comment.id.to_s, format: :json, comment: comment_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#destroy' do
    context 'with ability' do
      before do
        ability.can :destroy, Comment
        allow(Comment).to receive(:find) { comment }
        allow(comment).to receive(:destroy!) { true }
      end

      it 'expect to assign @comment' do
        delete :destroy, id: comment.id.to_s, format: :json
        expect(assigns(:comment)).not_to be_nil
      end

      it 'expect to receive :destroy!' do
        expect(comment).to receive(:destroy!)
        delete :destroy, id: comment.id.to_s, format: :json
      end

      it 'expect to render show template' do
        delete :destroy, id: comment.id.to_s, format: :json
        expect(response).to render_template('show')
      end
    end

    context 'without ability' do
      before { ability.cannot :destroy, Comment }

      it 'expect to raise CanCan::AccessDenied' do
        expect {delete :destroy, id: comment.id.to_s, format: :json}.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end