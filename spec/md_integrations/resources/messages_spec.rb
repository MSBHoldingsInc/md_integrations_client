require 'spec_helper'

RSpec.describe MdIntegrations::Resources::Messages, :mdi do
  let(:messages)  { mdi_client.messages }
  let(:patient_id) { 'p1' }
  let(:message_id) { 'm1' }

  it 'lists messages with default patient channel' do
    stub = stub_mdi(:get, "/partner/patients/#{patient_id}/messages",
                    query: { channel: 'patient' },
                    response_body: { data: [] })

    messages.list(patient_id)
    expect(stub).to have_been_requested
  end

  it 'finds a single message' do
    stub = stub_mdi(:get, "/partner/patients/#{patient_id}/messages/#{message_id}",
                    response_body: { id: message_id })

    messages.find(patient_id, message_id)
    expect(stub).to have_been_requested
  end

  it 'sends a message with default channel' do
    stub = stub_mdi(:post, "/partner/patients/#{patient_id}/messages",
                    request_body: { text: 'hi', channel: 'patient' }.to_json,
                    response_body: { id: message_id })

    messages.send_message(patient_id: patient_id, text: 'hi')
    expect(stub).to have_been_requested
  end

  it 'sends a message with attachments and custom channel' do
    stub = stub_mdi(:post, "/partner/patients/#{patient_id}/messages",
                    request_body: {
                      text: 'hi',
                      channel: 'support',
                      files: [{ id: 'f1' }]
                    }.to_json,
                    response_body: { id: message_id })

    messages.send_message(
      patient_id: patient_id,
      text: 'hi',
      channel: described_class::CHANNEL_SUPPORT,
      files: [{ id: 'f1' }]
    )
    expect(stub).to have_been_requested
  end

  it 'marks a message read' do
    stub = stub_mdi(:post, "/partner/patients/#{patient_id}/messages/#{message_id}/read",
                    response_body: { ok: true })

    messages.mark_read(patient_id, message_id)
    expect(stub).to have_been_requested
  end

  it 'marks a message unread' do
    stub = stub_mdi(:delete, "/partner/patients/#{patient_id}/messages/#{message_id}/unread",
                    response_body: { ok: true })

    messages.mark_unread(patient_id, message_id)
    expect(stub).to have_been_requested
  end

  it 'finds a notification record' do
    stub = stub_mdi(:get, '/partner/messages/notifications/notif-1',
                    response_body: { id: 'notif-1' })

    messages.find_notification('notif-1')
    expect(stub).to have_been_requested
  end
end
