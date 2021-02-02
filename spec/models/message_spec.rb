# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  context 'with validations' do
    it { is_expected.to validate_presence_of(:inbox_id) }
    it { is_expected.to validate_presence_of(:conversation_id) }
    it { is_expected.to validate_presence_of(:account_id) }
  end

  context 'when message is created' do
    let(:message) { build(:message, account: create(:account)) }

    it 'triggers ::MessageTemplates::HookExecutionService' do
      hook_execution_service = double
      allow(::MessageTemplates::HookExecutionService).to receive(:new).and_return(hook_execution_service)
      allow(hook_execution_service).to receive(:perform).and_return(true)

      message.save!

      expect(::MessageTemplates::HookExecutionService).to have_received(:new).with(message: message)
      expect(hook_execution_service).to have_received(:perform)
    end

    it 'calls notify email method on after save for outgoing messages' do
      allow(ConversationReplyEmailWorker).to receive(:perform_in).and_return(true)
      message.message_type = 'outgoing'
      message.save!
      expect(ConversationReplyEmailWorker).to have_received(:perform_in)
    end

    it 'wont call notify email method for private notes' do
      message.private = true
      allow(ConversationReplyEmailWorker).to receive(:perform_in).and_return(true)
      message.save!
      expect(ConversationReplyEmailWorker).not_to have_received(:perform_in)
    end

    it 'wont call notify email method unless its website or email channel' do
      message.inbox = create(:inbox, account: message.account, channel: build(:channel_api, account: message.account))
      allow(ConversationReplyEmailWorker).to receive(:perform_in).and_return(true)
      message.save!
      expect(ConversationReplyEmailWorker).not_to have_received(:perform_in)
    end
  end
end
