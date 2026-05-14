module MdIntegrations
  module Resources
    # Information about the authenticated partner account (this Rugiet account).
    class Partner < Base
      # Get the authenticated partner. Useful as a credential/health check.
      def me
        connection.get('/partner')
      end
    end
  end
end
