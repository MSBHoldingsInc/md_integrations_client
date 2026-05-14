module ResourceHelpers
  CLIENT_ID     = 'cid'.freeze
  CLIENT_SECRET = 'csecret'.freeze
  ACCESS_TOKEN  = 'test-access-token'.freeze
  BASE_URL      = MdIntegrations::Configuration::BASE_URL

  def mdi_client
    @mdi_client ||= MdIntegrations::Client.new(
      client_id:     CLIENT_ID,
      client_secret: CLIENT_SECRET,
      environment:   :sandbox
    )
  end

  def stub_mdi_auth
    stub_request(:post, "#{BASE_URL}#{MdIntegrations::Auth::TokenManager::AUTH_PATH}")
      .to_return(
        status:  200,
        body:    { access_token: ACCESS_TOKEN, expires_in: 86_400 }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_mdi(method, path, status: 200, response_body: {}, request_body: nil, query: nil)
    url = "#{BASE_URL}#{path}"
    stub = stub_request(method, url)
    stub = stub.with(body: request_body) if request_body
    stub = stub.with(query: query) if query
    stub.to_return(
      status:  status,
      body:    response_body.is_a?(String) ? response_body : response_body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end

RSpec.configure do |config|
  config.include ResourceHelpers

  config.before(:each, :mdi) do
    stub_mdi_auth
  end
end
