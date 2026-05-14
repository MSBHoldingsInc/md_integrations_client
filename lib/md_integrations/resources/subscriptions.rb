module MdIntegrations
  module Resources
    # MDI-side subscriptions tracking. (Rugiet manages its own subscriptions
    # in-house; use these endpoints only if syncing subscription state with MDI.)
    class Subscriptions < Base
      BASE_PATH = '/partner/subscriptions'.freeze

      def list(params = { page: 1, per_page: 15 })
        connection.get(BASE_PATH, params)
      end

      def find(subscription_id)
        connection.get("#{BASE_PATH}/#{subscription_id}")
      end

      def create(payload)
        connection.post(BASE_PATH, payload)
      end

      def update(subscription_id, payload)
        connection.patch("#{BASE_PATH}/#{subscription_id}", payload)
      end

      def cancel(subscription_id, payload = {})
        connection.post("#{BASE_PATH}/#{subscription_id}/cancel", payload)
      end

      def delete(subscription_id)
        connection.delete("#{BASE_PATH}/#{subscription_id}")
      end
    end
  end
end
