require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:project) { FactoryGirl.create(:project, user: user) }
  let!(:project_prms) { FactoryGirl.attributes_for(:project) }
  let(:ability) { create_ability }

  before { allow(controller).to receive(:current_user) { user } }

  describe '#index' do
    context 'with ability' do
      before { ability.can :read, Project }

      it 'expect to render index template' do
        get :index, format: :json
        expect(response).to render_template('index')
      end

      it 'expect to assign @projects' do
        get :index, format: :json
        expect(assigns(:projects)).not_to be_nil
      end
    end

    context 'without abilities' do
      before { ability.cannot :read, Project }

      it 'expect to raise CanCan::AccessDenied' do
        expect { get :index, format: :json }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#create' do
    context 'with ability' do
      before { ability.can :create, Project }

      context 'prms valid' do
        before do
          allow(Project).to receive(:new) { project }
          allow(project).to receive(:save!) { true }
        end

        it 'expect to assign @project' do
          post :create, format: :json, project: project_prms
          expect(assigns(:project)).not_to be_nil
        end

        it 'expect to receive :save!' do
          expect(project).to receive(:save!)
          post :create, format: :json, project: project_prms
        end

        it 'expect to render create template' do
          post :create, format: :json, project: project_prms
          expect(response).to render_template('create')
        end
      end

      context 'prms invalid' do
        before { project_prms[:title] = '' }

        it { expect {post :create, format: :json, project: project_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :create, Project }

      it 'expect to raise CanCan::AccessDenied' do
        expect {post :create, format: :json, project: project_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#update' do
    context 'with ability' do
      before { ability.can :update, Project }

      context 'prms valid' do
        before do
          allow(user).to receive_message_chain(:projects, :find) { project }
          allow(project).to receive(:update!) { true }
        end

        it 'expect to assign @project' do
          put :update, id: project.id.to_s, format: :json, project: project_prms
          expect(assigns(:project)).not_to be_nil
        end

        it 'expect to receive :save!' do
          expect(project).to receive(:update!)
          put :update, id: project.id.to_s, format: :json, project: project_prms
        end

        it 'expect to render update template' do
          put :update, id: project.id.to_s, format: :json, project: project_prms
          expect(response).to render_template('update')
        end
      end

      context 'prms invalid' do
        before { project_prms[:title] = '' }

        it { expect {put :update, id: project.id.to_s, format: :json, project: project_prms}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end

    context 'without ability' do
      before { ability.cannot :update, Project }

      it 'expect to raise CanCan::AccessDenied' do
        expect {put :update, id: project.id.to_s, format: :json, project: project_prms}.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#destroy' do
    context 'with ability' do
      before do
        ability.can :destroy, Project
        allow(user).to receive_message_chain(:projects, :find) { project }
        allow(project).to receive(:destroy!) { true }
      end

      it 'expect to assign @project' do
        delete :destroy, id: project.id.to_s, format: :json
        expect(assigns(:project)).not_to be_nil
      end

      it 'expect to receive :destroy!' do
        expect(project).to receive(:destroy!)
        delete :destroy, id: project.id.to_s, format: :json
      end

      it 'expect to render destroy template' do
        delete :destroy, id: project.id.to_s, format: :json
        expect(response).to render_template('destroy')
      end
    end

    context 'without ability' do
      before { ability.cannot :destroy, Project }

      it 'expect to raise CanCan::AccessDenied' do
        expect {delete :destroy, id: project.id.to_s, format: :json}.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
