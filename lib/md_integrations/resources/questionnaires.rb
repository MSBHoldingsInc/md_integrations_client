module MdIntegrations
  module Resources
    # Look up questionnaires configured for the partner.
    # One questionnaire_id per Rugiet SKU (NAD+, Glutathione, Sermorelin, Lipo-C, L-Carnitine).
    class Questionnaires < Base
      BASE_PATH = '/partner/questionnaires'.freeze

      def list(params = {})
        connection.get(BASE_PATH, params)
      end

      def find(questionnaire_id)
        connection.get("#{BASE_PATH}/#{questionnaire_id}")
      end

      def questions(questionnaire_id)
        connection.get("#{BASE_PATH}/#{questionnaire_id}/questions")
      end
    end
  end
end
