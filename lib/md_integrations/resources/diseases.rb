module MdIntegrations
  module Resources
    # ICD-based disease lookup (used when creating cases or attaching diseases).
    class Diseases < Base
      BASE_PATH = '/partner/metadata/diseases'.freeze

      def list(params = {})
        connection.get(BASE_PATH, params)
      end

      def find(disease_id)
        connection.get("#{BASE_PATH}/#{disease_id}")
      end
    end
  end
end
