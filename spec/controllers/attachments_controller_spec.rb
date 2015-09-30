require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:project) { FactoryGirl.create(:project, user: user) }
  let!(:task) { FactoryGirl.create(:task, project: project) }
  let!(:comment) { FactoryGirl.create(:comment, task: task) }
  let!(:attachment) { FactoryGirl.create(:attachment, comment: comment) }
  let(:ability) { create_ability }

  before do
    allow(Attachment).to receive(:find) { attachment }
    allow(controller).to receive(:current_user) { user }
  end

  describe '#destroy' do
    context 'with ability' do
      before do
        ability.can :destroy, Attachment
        allow(attachment).to receive(:destroy!) { true }
      end

      it 'expect to assign @attachment' do
        delete :destroy, id: attachment.id.to_s, format: :json
        expect(assigns(:attachment)).not_to be_nil
      end

      it 'expect to receive :destroy!' do
        expect(attachment).to receive(:destroy!)
        delete :destroy, id: attachment.id.to_s, format: :json
      end

      it 'expect to render destroy template' do
        delete :destroy, id: attachment.id.to_s, format: :json
        expect(response).to render_template('destroy')
      end
    end

    context 'without ability' do
      before { ability.cannot :destroy, Attachment }

      it 'expect to raise CanCan::AccessDenied' do
        expect {delete :destroy, id: attachment.id.to_s, format: :json}.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end