module MdIntegrations
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class AuthenticationError < Error; end

  class APIError < Error
    attr_reader :status, :body

    def initialize(message, status: nil, body: nil)
      @status = status
      @body = body
      super(message)
    end
  end

  class BadRequestError < APIError; end
  class ForbiddenError < APIError; end
  class NotFoundError < APIError; end
  class ValidationError < APIError; end
  class RateLimitError < APIError; end
  class MaintenanceError < APIError; end
  class ServerError < APIError; end

  class NetworkError < Error; end

  class WebhookSignatureError < Error; end
end
