module MdIntegrations
  module Resources
    class Notifications < Base
      BASE_PATH = '/partner/notifications'.freeze

      def list(params = {})
        connection.get(BASE_PATH, params)
      end

      def find(notification_id)
        connection.get("#{BASE_PATH}/#{notification_id}")
      end
    end
  end
end
