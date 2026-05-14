module MdIntegrations
  module Resources
    # Look up clinician info (name, NPI, signature, specialty).
    # Used when generating Rx labels that need prescriber details.
    class Clinicians < Base
      BASE_PATH = '/partner/clinicians'.freeze

      def find(clinician_id)
        connection.get("#{BASE_PATH}/#{clinician_id}")
      end
    end
  end
end
