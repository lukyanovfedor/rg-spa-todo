require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:project) { FactoryGirl.create(:project, user: user) }
  let!(:task) { FactoryGirl.create(:task, project: project) }
  let!(:task_prms) { FactoryGirl.attributes_for(:task) }
  let(:ability) { create_ability }

  before do
    ability.can :manage, Project
    allow(Project).to receive(:find) { project }
    allow(controller).to receive(:current_user) { user }
  end

  describe '#index' do
    context 'with ability' do
      before { ability.can :read, Task }

      it 'expect to render index template' do
        get :index, project_id: project.id.to_s, format: :json
        expect(response).to render_template('index')
      end

      it 'expect to assign @tasks' do
        get :index, project_id: project.id.to_s, format: :json
        expect(assigns(:tasks)).not_to be_nil
      end
    end

    context 'without abilities' do
      before { ability.cannot :read, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect { get :index, project_id: project.id.to_s, format: :json }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#create' do
    context 'with ability' do
      before { ability.can :create, Task }

      context 'prms valid' do
        before do
          allow(Task).to receive(:new) { task }
          allow(task).to receive(:save!) { true }
        end

        it 'expect to assign @task' do
          post :create, format: :json, project_id: project.id.to_s, task: task_prms
          expect(assigns(:task)).not_to be_nil
        end

        it 'expect to receive :save!' do
          expect(task).to receive(:save!)
          post :create, format: :json, project_id: project.id.to_s, task: task_prms
        end

        it 'expect to render show template' do
          post :create, format: :json, project_id: project.id.to_s, task: task_prms
          expect(response).to render_template('show')
        end
      end

      context 'prms invalid' do
        before { task_prms[:title] = '' }

        it { expect {post :create, format: :json, project_id: project.id.to_s, task: task_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :create, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect {post :create, format: :json, project_id: project.id.to_s, task: task_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#update' do
    context 'with ability' do
      before { ability.can :update, Task }

      context 'prms valid' do
        before do
          allow(Task).to receive(:find) { task }
          allow(task).to receive(:update!) { true }
        end

        it 'expect to assign @task' do
          put :update, id: task.id.to_s, format: :json, task: task_prms
          expect(assigns(:task)).not_to be_nil
        end

        it 'expect to receive :update!' do
          expect(task).to receive(:update!)
          put :update, id: task.id.to_s, format: :json, task: task_prms
        end

        it 'expect to render show template' do
          put :update, id: task.id.to_s, format: :json, task: task_prms
          expect(response).to render_template('show')
        end
      end

      context 'prms invalid' do
        before { task_prms[:title] = '' }

        it { expect {put :update, id: task.id.to_s, format: :json, task: task_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :update, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect {put :update, id: task.id.to_s, format: :json, task: task_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#destroy' do
    context 'with ability' do
      before do
        ability.can :destroy, Task
        allow(Task).to receive(:find) { task }
        allow(task).to receive(:destroy!) { true }
      end

      it 'expect to assign @task' do
        delete :destroy, id: task.id.to_s, format: :json
        expect(assigns(:task)).not_to be_nil
      end

      it 'expect to receive :destroy!' do
        expect(task).to receive(:destroy!)
        delete :destroy, id: task.id.to_s, format: :json
      end

      it 'expect to render show template' do
        delete :destroy, id: task.id.to_s, format: :json
        expect(response).to render_template('show')
      end
    end

    context 'without ability' do
      before { ability.cannot :destroy, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect {delete :destroy, id: task.id.to_s, format: :json}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#show' do
    context 'with ability' do
      before { ability.can :read, Task }

      it 'expect to render show template' do
        get :show, id: task.id.to_s, format: :json
        expect(response).to render_template('show')
      end

      it 'expect to assign @task' do
        get :show, id: task.id.to_s, format: :json
        expect(assigns(:task)).not_to be_nil
      end
    end

    context 'without abilities' do
      before { ability.cannot :read, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect { get :show, id: task.id.to_s, format: :json }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#toggle' do
    context 'with ability' do
      before do
        ability.can :manage, Task
        allow(Task).to receive(:find) { task }
      end

      it 'expect to assign @task' do
        put :toggle, id: task.id.to_s, format: :json
        expect(assigns(:task)).not_to be_nil
      end

      it 'expect to receive :toggle!' do
        expect(task).to receive(:toggle!)
        put :toggle, id: task.id.to_s, format: :json
      end

      it 'expect to render show template' do
        put :toggle, id: task.id.to_s, format: :json
        expect(response).to render_template('show')
      end
    end

    context 'without ability' do
      before { ability.cannot :manage, Task }

      it 'expect to raise CanCan::AccessDenied' do
        expect {put :toggle, id: task.id.to_s, format: :json}.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end