module MdIntegrations
  class Configuration
    # MDI uses the same base URL for both sandbox and production.
    # Sandbox vs production traffic is distinguished by which credentials
    # (client_id / client_secret) you authenticate with.
    BASE_URL = 'https://api.mdintegrations.com'.freeze

    ENVIRONMENTS = %i[sandbox production].freeze

    attr_reader :client_id, :client_secret, :environment, :base_url,
                :logger, :timeout, :open_timeout

    def initialize(client_id:, client_secret:, environment: :sandbox,
                   base_url: nil, logger: nil, timeout: 30, open_timeout: 10)
      @client_id     = client_id
      @client_secret = client_secret
      @environment   = environment.to_sym
      @base_url      = base_url || BASE_URL
      @logger        = logger
      @timeout       = timeout
      @open_timeout  = open_timeout

      validate!
    end

    def sandbox?
      environment == :sandbox
    end

    def production?
      environment == :production
    end

    private

    def validate!
      raise ConfigurationError, 'client_id is required'     if client_id.to_s.empty?
      raise ConfigurationError, 'client_secret is required' if client_secret.to_s.empty?
      raise ConfigurationError, 'base_url is required'      if base_url.to_s.empty?
      raise ConfigurationError, "Unknown environment: #{environment}. Use :sandbox or :production." unless ENVIRONMENTS.include?(environment)
    end
  end
end
