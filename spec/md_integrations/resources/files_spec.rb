require 'spec_helper'
require 'stringio'

RSpec.describe MdIntegrations::Resources::Files, :mdi do
  let(:files)   { mdi_client.files }
  let(:file_id) { 'f1' }

  describe '#upload' do
    it 'POSTs multipart form-data to /partner/files with the right field set' do
      stub = stub_request(:post, "#{ResourceHelpers::BASE_URL}/partner/files")
             .with(headers: { 'Authorization' => "Bearer #{ResourceHelpers::ACCESS_TOKEN}" }) do |req|
               body = req.body.to_s
               body.include?('name="name"') &&
                 body.include?('name="type"') &&
                 body.include?('driver-license') &&
                 body.include?('name="file"') &&
                 body.include?('license.jpg')
             end
             .to_return(
               status:  200,
               body:    { id: file_id }.to_json,
               headers: { 'Content-Type' => 'application/json' }
             )

      io = StringIO.new('fake-jpeg-bytes')
      result = files.upload(
        io:           io,
        filename:     'license.jpg',
        content_type: 'image/jpeg',
        type:         described_class::TYPE_DRIVER_LICENSE
      )

      expect(result).to eq('id' => file_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#find' do
    it 'GETs /partner/files/:id' do
      stub = stub_mdi(:get, "/partner/files/#{file_id}",
                      response_body: { id: file_id })

      files.find(file_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'DELETEs /partner/files/:id' do
      stub = stub_mdi(:delete, "/partner/files/#{file_id}",
                      response_body: { ok: true })

      files.delete(file_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'multipart upload error handling' do
    let(:upload_url) { "#{ResourceHelpers::BASE_URL}/partner/files" }

    def call_upload
      files.upload(
        io:           StringIO.new('bytes'),
        filename:     'x.jpg',
        content_type: 'image/jpeg',
        type:         described_class::TYPE_LAB_RESULT
      )
    end

    it 'retries once on 401 with a fresh token' do
      upload_stub = stub_request(:post, upload_url).to_return(
        { status: 401, body: '{}',                              headers: { 'Content-Type' => 'application/json' } },
        { status: 200, body: { file_id: 'f1' }.to_json,         headers: { 'Content-Type' => 'application/json' } }
      )
      auth_url = "#{ResourceHelpers::BASE_URL}#{MdIntegrations::Auth::TokenManager::AUTH_PATH}"

      expect(call_upload).to eq('file_id' => 'f1')
      expect(upload_stub).to have_been_requested.times(2)
      expect(WebMock).to have_requested(:post, auth_url).at_least_times(2)
    end

    it 'wraps Faraday timeouts as NetworkError' do
      stub_request(:post, upload_url).to_timeout

      expect { call_upload }.to raise_error(MdIntegrations::NetworkError, /Network error talking to MDI/)
    end

    it 'wraps Faraday connection failures as NetworkError' do
      stub_request(:post, upload_url).to_raise(Faraday::ConnectionFailed.new('boom'))

      expect { call_upload }.to raise_error(MdIntegrations::NetworkError, /Network error talking to MDI/)
    end
  end
end
