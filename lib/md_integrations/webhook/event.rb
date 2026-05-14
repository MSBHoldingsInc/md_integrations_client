module MdIntegrations
  module Webhook
    class Event
      attr_reader :raw

      def initialize(raw)
        @raw = raw.is_a?(Hash) ? raw : JSON.parse(raw.to_s)
      end

      def type
        raw['event_type']
      end

      def timestamp
        raw['timestamp']
      end

      def case_id
        raw['case_id']
      end

      def patient_id
        raw['patient_id']
      end

      def metadata
        raw['metadata']
      end

      def offerings
        raw['offerings'] || []
      end

      def [](key)
        raw[key.to_s]
      end

      def case_event?
        type.to_s.start_with?('case_')
      end

      def order_event?
        type.to_s.start_with?('order_')
      end

      def patient_event?
        type.to_s.start_with?('patient_')
      end

      def message_event?
        type == EventTypes::MESSAGE_CREATED
      end

      def offering_submitted?
        type == EventTypes::OFFERING_SUBMITTED
      end
    end
  end
end
