module MdIntegrations
  module Resources
    # Case-scoped order management. Use to push fulfillment status, tracking
    # numbers, and cancellations back to MDI after we ship from our pharmacy.
    class Orders < Base
      def list(case_id)
        connection.get("/partner/cases/#{case_id}/orders")
      end

      def events(case_id, order_id, params = { page: 1, per_page: 15 })
        connection.get("/partner/cases/#{case_id}/orders/#{order_id}/events", params)
      end

      def submit(case_id, order_id, payload = {})
        connection.post("/partner/cases/#{case_id}/orders/#{order_id}/submit", payload)
      end

      def cancel(case_id, order_id, payload = {})
        connection.post("/partner/cases/#{case_id}/orders/#{order_id}/cancel", payload)
      end

      def update(case_id, order_id, payload)
        connection.patch("/partner/cases/#{case_id}/orders/#{order_id}", payload)
      end
    end
  end
end
