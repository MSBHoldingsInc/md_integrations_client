require 'spec_helper'
require 'stringio'
require 'logger'

RSpec.describe MdIntegrations::Connection do
  let(:log_io) { StringIO.new }
  let(:logger) { Logger.new(log_io) }
  let(:client) do
    MdIntegrations::Client.new(
      client_id:     'cid',
      client_secret: 'csecret',
      environment:   :sandbox,
      logger:        logger
    )
  end
  let(:token_url) { "#{MdIntegrations::Configuration::BASE_URL}#{MdIntegrations::Auth::TokenManager::AUTH_PATH}" }
  let(:secret_token) { 'SECRET-ACCESS-TOKEN-DO-NOT-LOG' }

  before do
    stub_request(:post, token_url)
      .to_return(
        status:  200,
        body:    { access_token: secret_token, expires_in: 86_400 }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'logger hygiene' do
    it 'redacts the Bearer token from logged requests' do
      stub_request(:get, "#{MdIntegrations::Configuration::BASE_URL}/partner")
        .to_return(status: 200, body: { id: 'rugiet' }.to_json)

      client.partner.me

      expect(log_io.string).not_to include(secret_token)
      expect(log_io.string).to match(/\[REDACTED\]/)
    end

    it 'does not log request or response bodies' do
      payload = { secret_field: 'PHI-DO-NOT-LOG' }
      stub_request(:post, "#{MdIntegrations::Configuration::BASE_URL}/partner/patients")
        .to_return(status: 200, body: { sensitive: 'RESPONSE-PHI' }.to_json)

      client.patients.create(payload)

      expect(log_io.string).not_to include('PHI-DO-NOT-LOG')
      expect(log_io.string).not_to include('RESPONSE-PHI')
    end
  end
end
