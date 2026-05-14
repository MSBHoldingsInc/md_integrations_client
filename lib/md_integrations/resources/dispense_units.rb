module MdIntegrations
  module Resources
    # Dispense unit catalog. Used in case_offerings payloads where the
    # `dispense_unit` field is required (e.g., "tablet", "vial", "mL").
    class DispenseUnits < Base
      BASE_PATH = '/partner/dispense-units'.freeze

      def list(params = {})
        connection.get(BASE_PATH, params)
      end
    end
  end
end
