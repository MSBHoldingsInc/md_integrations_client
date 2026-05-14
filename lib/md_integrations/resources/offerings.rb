module MdIntegrations
  module Resources
    class Offerings < Base
      # === Listing offerings on a case ===

      def list_for_case(case_id)
        connection.get("/partner/cases/#{case_id}/offerings")
      end

      def find_on_case(case_id, offering_id)
        connection.get("/partner/cases/#{case_id}/offerings/#{offering_id}")
      end

      def create_on_case(case_id, payload)
        connection.post("/partner/cases/#{case_id}/offerings", payload)
      end

      def update_on_case(case_id, offering_id, payload)
        connection.patch("/partner/cases/#{case_id}/offerings/#{offering_id}", payload)
      end

      def delete_on_case(case_id, offering_id)
        connection.delete("/partner/cases/#{case_id}/offerings/#{offering_id}")
      end

      def update_statuses(case_id, statuses)
        connection.patch("/partner/cases/#{case_id}/offerings/status", statuses: statuses)
      end

      # === Catalog ===

      def list(params = {})
        connection.get('/partner/offerings', params)
      end
    end
  end
end
