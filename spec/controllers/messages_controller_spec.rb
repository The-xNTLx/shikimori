describe MessagesController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index, profile_id: user.to_param, messages_type: 'notifications' }
    it { expect(response).to have_http_status :success }
  end

  describe '#bounce' do
    let(:user) { create :user }
    before { sign_out user }
    before { post :bounce, Email: user.email }

    it do
      expect(response).to have_http_status :success
      expect(user.messages.size).to eq(1)
    end
  end

  describe '#show' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :show, id: message.id }

    context 'has access' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#edit' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :edit, id: message.id }

    context 'has access' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#preview' do
    let(:user) { create :user }
    before { post :preview, message: { body: 'test', from_id: user.id, to_id: user.id, kind: MessageType::Private } }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:message) { create :message, from: user }
    let(:params) {{ body: 'werdfghj' }}
    let(:make_request) { patch :update, id: message.id, message: params, format: :json }

    context 'has access' do
      before { make_request }

      it 'valid params' do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(resource).to have_attributes params
      end

      context 'invalid params' do
        let(:params) {{ body: '' }}
        it { expect(response).to have_http_status 422 }
      end
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create' do
    let(:target_user) { create :user }
    let(:kind) { MessageType::Private }
    let(:params) {{ from_id: user.id, to_id: target_user.id, body: body, kind: kind }}
    let(:body) { 'werdfghj' }
    let(:make_request) { post :create, message: params, format: :json }

    context 'has access' do
      before { make_request }

      it 'valid params' do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(resource).to have_attributes params
      end

      context 'invalid params' do
        let(:body) { '' }
        it { expect(response).to have_http_status 422 }
      end
    end

    context 'no access' do
      let(:kind) { MessageType::Notification }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#destroy' do
    let(:message) { create :message, :private, from: user }
    let(:make_request) { delete :destroy, id: message.id }

    context 'has access' do
      before { make_request }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(resource.src_del).to be_truthy
      end
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#mark_read' do
    let(:message_from) { create :message, from: user }
    let(:message_to) { create :message, to: user }
    before { post :mark_read, ids: "message-#{message_to.id},message-#{message_from.id},message-987654" }

    it do
      expect(response).to have_http_status :success
      expect(message_from.reload.read).to be_falsy
      expect(message_to.reload.read).to be_truthy
    end
  end

  describe '#read_all' do
    let!(:message_1) { create :message, :news, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :read_all, profile_id: user.to_param, messages_type: 'news' }

    it do
      expect(response).to redirect_to index_profile_messages_url(user.to_param, 'news')
      expect(message_1.reload).to be_read
      expect(message_2.reload).to_not be_read
      expect(message_3.reload).to_not be_read
    end
  end

  describe '#delete_all' do
    let!(:message_1) { create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :delete_all, profile_id: user.to_param, messages_type: 'notifications' }

    it do
      expect(response).to redirect_to index_profile_messages_url(user.to_param, 'notifications')
      expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound
      expect(message_2.reload).to be_persisted
      expect(message_3.reload).to be_persisted
    end
  end

  describe '#chosen' do
    let(:target_user) { create :user }
    let!(:message_1) { create :message, to: user, from: target_user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, to: target_user, from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: target_user, from: build_stubbed(:user) }

    before { get :chosen, ids: [message_1.id, message_2.id, message_3.id].join(',') }

    it do
      expect(response).to have_http_status :success
      expect(collection).to eq [message_1, message_2]
    end
  end

  describe '#unsubscribe' do
    let(:user) { create :user, notifications: User::PRIVATE_MESSAGES_TO_EMAIL }
    let(:make_request) { get :unsubscribe, name: user.nickname, kind: MessageType::Private, key: key }

    before { sign_out user }

    context 'valid key' do
      before { make_request }
      let(:key) { MessagesController.unsubscribe_key(user, MessageType::Private) }

      it do
        expect(response).to have_http_status :success
        expect(user.reload.notifications).to be_zero
      end
    end

    context 'invalid key' do
      let(:key) { 'asd' }
      it do
        expect{make_request}.to raise_error CanCan::AccessDenied
        expect(user.reload.notifications).to eq User::PRIVATE_MESSAGES_TO_EMAIL
      end
    end
  end
end
