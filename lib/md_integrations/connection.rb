require 'faraday'
require 'faraday/multipart'
require 'json'

module MdIntegrations
  class Connection
    JSON_CONTENT_TYPE = 'application/json'.freeze

    def initialize(configuration, token_manager)
      @configuration = configuration
      @token_manager = token_manager
    end

    def get(path, params = {})
      request(:get, path, params: params)
    end

    def post(path, body = {})
      request(:post, path, body: body)
    end

    def patch(path, body = {})
      request(:patch, path, body: body)
    end

    def put(path, body = {})
      request(:put, path, body: body)
    end

    def delete(path, params = {})
      request(:delete, path, params: params)
    end

    def post_multipart(path, parts = {}, retried: false)
      response = faraday.post(path) do |req|
        req.headers['Authorization'] = "Bearer #{token_manager.access_token}"
        req.headers['Accept']        = JSON_CONTENT_TYPE
        req.body = parts
      end

      if response.status == 401 && !retried
        token_manager.invalidate!
        return post_multipart(path, parts, retried: true)
      end

      handle_response(response, method: :post, path: path)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise NetworkError, "Network error talking to MDI: #{e.message}"
    end

    private

    attr_reader :configuration, :token_manager

    def request(method, path, params: nil, body: nil, retried: false)
      response = faraday.public_send(method) do |req|
        req.url path
        req.headers['Authorization'] = "Bearer #{token_manager.access_token}"
        req.headers['Content-Type']  = JSON_CONTENT_TYPE
        req.headers['Accept']        = JSON_CONTENT_TYPE
        req.params.update(params) if params && !params.empty?
        req.body = JSON.generate(body) if body && !body.empty?
      end

      if response.status == 401 && !retried
        token_manager.invalidate!
        return request(method, path, params: params, body: body, retried: true)
      end

      handle_response(response, method: method, path: path)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise NetworkError, "Network error talking to MDI: #{e.message}"
    end

    def handle_response(response, method:, path:)
      parsed = parse_body(response.body)

      case response.status
      when 200..299
        parsed
      when 400
        raise BadRequestError.new(error_message(parsed, fallback: 'Bad request'), status: response.status, body: parsed)
      when 401
        raise AuthenticationError, error_message(parsed, fallback: 'Unauthorized')
      when 403
        raise ForbiddenError.new(error_message(parsed, fallback: 'Forbidden'), status: response.status, body: parsed)
      when 404
        raise NotFoundError.new(error_message(parsed, fallback: "Not found: #{method.upcase} #{path}"), status: response.status, body: parsed)
      when 418
        raise MaintenanceError.new(error_message(parsed, fallback: 'MDI API is under maintenance'), status: response.status, body: parsed)
      when 422
        raise ValidationError.new(error_message(parsed, fallback: 'Validation error'), status: response.status, body: parsed)
      when 429
        raise RateLimitError.new(error_message(parsed, fallback: 'Rate limited'), status: response.status, body: parsed)
      when 500..599
        raise ServerError.new(error_message(parsed, fallback: "Server error (#{response.status})"), status: response.status, body: parsed)
      else
        raise APIError.new(error_message(parsed, fallback: "Unexpected status #{response.status}"), status: response.status, body: parsed)
      end
    end

    def parse_body(body)
      return body if body.is_a?(Hash) || body.is_a?(Array)
      return nil if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      body
    end

    # MDI error responses include both `error` (detailed, dev-facing) and
    # `message` (user-friendly). Prefer `message` for surfacing to end users.
    def error_message(parsed, fallback:)
      return fallback unless parsed.is_a?(Hash)

      parsed['message'] || parsed['error'] || parsed['errors']&.to_s || fallback
    end

    def faraday
      @faraday ||= Faraday.new(url: configuration.base_url) do |conn|
        conn.options.timeout      = configuration.timeout
        conn.options.open_timeout = configuration.open_timeout
        conn.request :multipart
        attach_logger(conn) if configuration.logger
        conn.adapter Faraday.default_adapter
      end
    end

    # Redact the Bearer token from any log line the Faraday logger middleware
    # would emit. Without this, passing `logger: Rails.logger` to the client
    # would dump `Authorization: Bearer <token>` into application logs on every
    # request. Bodies are suppressed entirely to keep PHI out of logs too.
    def attach_logger(conn)
      conn.response :logger, configuration.logger, headers: true, bodies: false do |logger|
        # Faraday's logger formats header values via #inspect, so the line
        # looks like:  Authorization: "Bearer eyJ0eXAi..."
        # Match the whole header value (quoted or not) and redact it.
        logger.filter(/(Authorization:\s*)"?Bearer\s+[^"\s]+"?/i, '\1[REDACTED]')
      end
    end
  end
end
