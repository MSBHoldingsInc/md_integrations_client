require 'faraday'
require 'json'

module MdIntegrations
  module Auth
    class TokenManager
      # MDI tokens are valid for 24 hours (per MDI doc + auth response `expires_in: 86400`).
      # We proactively refresh at 22 hours to keep a 2-hour safety margin and stay
      # within MDI's recommendation. The manager will also honor the `expires_in`
      # value MDI returns in the auth response and refresh sooner if needed.
      DEFAULT_TOKEN_TTL_SECONDS = 24 * 60 * 60
      REFRESH_BUFFER_SECONDS    = 2 * 60 * 60 # refresh 2 hours before expiry
      # Random jitter (0..N seconds) subtracted from the refresh threshold so
      # that multiple processes started in the same deploy don't all try to
      # refresh in lockstep when their tokens reach the 22-hour mark.
      REFRESH_JITTER_SECONDS    = 60

      AUTH_PATH  = '/v1/partner/auth/token'.freeze
      GRANT_TYPE = 'client_credentials'.freeze
      SCOPE      = '*'.freeze

      def initialize(configuration)
        @configuration = configuration
        @mutex         = Mutex.new
        @token         = nil
        @expires_at    = nil
      end

      def access_token
        @mutex.synchronize do
          fetch_new_token! if needs_refresh?
          @token
        end
      end

      def invalidate!
        @mutex.synchronize do
          @token      = nil
          @expires_at = nil
        end
      end

      private

      attr_reader :configuration

      def needs_refresh?
        return true if @token.nil? || @expires_at.nil?

        Time.now >= @expires_at
      end

      def fetch_new_token!
        response = auth_connection.post(AUTH_PATH) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept']       = 'application/json'
          req.body = JSON.generate(
            grant_type:    GRANT_TYPE,
            client_id:     configuration.client_id,
            client_secret: configuration.client_secret,
            scope:         SCOPE
          )
        end

        unless response.success?
          raise AuthenticationError, "Failed to fetch MDI access token (status: #{response.status}#{auth_error_reason(response.body)})"
        end

        body  = parse_body(response.body)
        token = body['access_token'] || body[:access_token]

        raise AuthenticationError, 'MDI auth response did not include access_token' if token.nil? || token.empty?

        ttl = (body['expires_in'] || body[:expires_in] || DEFAULT_TOKEN_TTL_SECONDS).to_i
        @token      = token
        @expires_at = Time.now + ttl - REFRESH_BUFFER_SECONDS - rand(REFRESH_JITTER_SECONDS)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
        raise NetworkError, "Network error reaching MDI auth endpoint: #{e.message}"
      end

      # Auth connection deliberately does NOT attach a Faraday logger — the auth
      # request body contains client_secret and the success response contains
      # the access_token. Nothing here should ever land in application logs.
      def auth_connection
        @auth_connection ||= Faraday.new(url: configuration.base_url) do |conn|
          conn.options.timeout      = configuration.timeout
          conn.options.open_timeout = configuration.open_timeout
          conn.adapter Faraday.default_adapter
        end
      end

      # Pull the human-readable reason out of MDI's error envelope without
      # echoing the full response body into exception messages (which often
      # flow to Sentry/Rollbar/Datadog).
      def auth_error_reason(body)
        parsed = parse_body(body)
        return '' unless parsed.is_a?(Hash)

        msg = parsed['message'] || parsed['error']
        msg ? ", reason: #{msg}" : ''
      end

      def parse_body(body)
        return body if body.is_a?(Hash)

        JSON.parse(body.to_s)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
