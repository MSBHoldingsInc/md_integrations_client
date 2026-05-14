require 'spec_helper'

RSpec.describe MdIntegrations::Auth::TokenManager do
  let(:configuration) do
    MdIntegrations::Configuration.new(
      client_id: 'cid',
      client_secret: 'csecret',
      environment: :sandbox
    )
  end
  let(:manager) { described_class.new(configuration) }

  let(:token_url) { "#{configuration.base_url}#{described_class::AUTH_PATH}" }

  describe '#access_token' do
    it 'fetches a token on first call and caches it for subsequent calls' do
      stub = stub_request(:post, token_url)
             .to_return(status: 200, body: { access_token: 'abc.def.ghi' }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect(manager.access_token).to eq('abc.def.ghi')
      expect(manager.access_token).to eq('abc.def.ghi')
      expect(stub).to have_been_requested.once
    end

    it 'raises AuthenticationError when MDI returns a non-success status' do
      stub_request(:post, token_url).to_return(status: 401, body: { error: 'bad credentials' }.to_json)

      expect { manager.access_token }.to raise_error(MdIntegrations::AuthenticationError)
    end

    it 'raises AuthenticationError when response has no access_token' do
      stub_request(:post, token_url).to_return(status: 200, body: {}.to_json)

      expect { manager.access_token }.to raise_error(MdIntegrations::AuthenticationError, /did not include access_token/)
    end

    it 'does not echo the raw response body in the failure message' do
      body = { error: 'unauthorized', message: 'bad credentials', echo: 'SECRET-VALUE-XYZ' }.to_json
      stub_request(:post, token_url).to_return(status: 401, body: body)

      expect { manager.access_token }.to raise_error(MdIntegrations::AuthenticationError) do |e|
        expect(e.message).not_to include('SECRET-VALUE-XYZ')
        expect(e.message).not_to include('echo')
        expect(e.message).to include('bad credentials')
        expect(e.message).to include('401')
      end
    end

    it 'does not include the success body when access_token is missing' do
      stub_request(:post, token_url).to_return(
        status: 200,
        body:   { token_type: 'Bearer', refresh_token: 'SHOULD-NOT-LEAK' }.to_json
      )

      expect { manager.access_token }.to raise_error(MdIntegrations::AuthenticationError) do |e|
        expect(e.message).not_to include('SHOULD-NOT-LEAK')
        expect(e.message).not_to include('refresh_token')
      end
    end

    it 'wraps Faraday timeouts as NetworkError' do
      stub_request(:post, token_url).to_timeout

      expect { manager.access_token }.to raise_error(MdIntegrations::NetworkError, /Network error reaching MDI auth endpoint/)
    end

    it 'wraps Faraday connection failures as NetworkError' do
      stub_request(:post, token_url).to_raise(Faraday::ConnectionFailed.new('connection refused'))

      expect { manager.access_token }.to raise_error(MdIntegrations::NetworkError, /Network error reaching MDI auth endpoint/)
    end
  end

  describe 'refresh scheduling' do
    it 'subtracts buffer + random jitter from the server-provided TTL' do
      stub_request(:post, token_url).to_return(
        status: 200,
        body:   { access_token: 'tok', expires_in: 100_000 }.to_json
      )

      frozen = Time.utc(2026, 5, 14, 12, 0, 0)
      allow(Time).to receive(:now).and_return(frozen)
      allow(manager).to receive(:rand).with(described_class::REFRESH_JITTER_SECONDS).and_return(17)

      manager.access_token

      expected = frozen + 100_000 - described_class::REFRESH_BUFFER_SECONDS - 17
      expect(manager.instance_variable_get(:@expires_at)).to eq(expected)
    end
  end

  describe '#invalidate!' do
    it 'forces a fresh fetch on the next access_token call' do
      stub = stub_request(:post, token_url)
             .to_return(
               { status: 200, body: { access_token: 'first' }.to_json },
               { status: 200, body: { access_token: 'second' }.to_json }
             )

      expect(manager.access_token).to eq('first')
      manager.invalidate!
      expect(manager.access_token).to eq('second')
      expect(stub).to have_been_requested.twice
    end
  end
end
