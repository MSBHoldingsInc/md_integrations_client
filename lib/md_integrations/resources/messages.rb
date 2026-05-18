module MdIntegrations
  module Resources
    class Messages < Base
      CHANNEL_PATIENT = 'patient'.freeze
      CHANNEL_SUPPORT = 'support'.freeze

      def list(patient_id, params = { channel: CHANNEL_PATIENT })
        connection.get("/partner/patients/#{patient_id}/messages", params)
      end

      def find(patient_id, message_id)
        connection.get("/partner/patients/#{patient_id}/messages/#{message_id}")
      end

      # Supports optional `files: [{id: 'file-uuid'}]` and `reference_message_id` via **extra.
      def send_message(patient_id:, text:, channel: CHANNEL_PATIENT, **extra)
        payload = { text: text, channel: channel }.merge(extra)
        connection.post("/partner/patients/#{patient_id}/messages", payload)
      end

      def mark_read(patient_id, message_id)
        connection.post("/partner/patients/#{patient_id}/messages/#{message_id}/read")
      end

      def mark_unread(patient_id, message_id)
        connection.delete("/partner/patients/#{patient_id}/messages/#{message_id}/unread")
      end

      # Get a notification record (e.g., for tracing a SMS/email MDI sent).
      def find_notification(notification_id)
        connection.get("/partner/messages/notifications/#{notification_id}")
      end
    end
  end
end
