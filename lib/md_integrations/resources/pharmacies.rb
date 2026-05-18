module MdIntegrations
  module Resources
    # Pharmacy directory + partner-linked pharmacy listing.
    # Use this to look up DoseSpot pharmacy IDs (e.g., for TPH).
    class Pharmacies < Base
      BASE_PATH = '/partner/pharmacies'.freeze

      def list(params = {})
        connection.get(BASE_PATH, params)
      end

      def find(pharmacy_id)
        connection.get("#{BASE_PATH}/#{pharmacy_id}")
      end

      # Pharmacies linked to the authenticated partner (e.g., TPH if MDI
      # has connected it at the partner level).
      def linked(params = { page: 1, per_page: 100 })
        connection.get('/partner/linked-pharmacies', params)
      end
    end
  end
end
