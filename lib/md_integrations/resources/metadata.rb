module MdIntegrations
  module Resources
    # Reference data: states, cities, zipcodes, license types.
    # (Diseases are exposed as their own resource since they're commonly used.)
    class Metadata < Base
      def states
        connection.get('/partner/metadata/states')
      end

      def cities(state_id, search: nil)
        params = {}
        params[:search] = search if search
        connection.get("/partner/metadata/states/#{state_id}/cities", params)
      end

      def zipcode_lookup(zipcode)
        connection.get('/partner/metadata/zipcodes', search: zipcode)
      end

      def license_types
        connection.get('/partner/metadata/license-types')
      end
    end
  end
end
