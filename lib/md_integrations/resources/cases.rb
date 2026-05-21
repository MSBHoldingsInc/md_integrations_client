module MdIntegrations
  module Resources
    class Cases < Base
      BASE_PATH = '/partner/cases'.freeze

      # MDI case statuses
      STATUS_CREATED    = 'created'.freeze
      STATUS_ASSIGNED   = 'assigned'.freeze
      STATUS_WAITING    = 'waiting'.freeze
      STATUS_CANCELLED  = 'cancelled'.freeze
      STATUS_SUPPORT    = 'support'.freeze
      STATUS_PROCESSING = 'processing'.freeze
      STATUS_COMPLETED  = 'completed'.freeze

      # === Core ===

      def create(payload)
        connection.post(BASE_PATH, payload)
      end

      def find(case_id)
        connection.get("#{BASE_PATH}/#{case_id}")
      end

      def by_status(status, filters = {})
        connection.post("#{BASE_PATH}/status/#{status}", filters)
      end

      def status_count(filters = {})
        connection.get('/partner/statistics/count/cases-by-status', filters)
      end

      def create_follow_up(reference_case_id:, **payload)
        create(payload.merge(reference_case_id: reference_case_id))
      end

      # === Status transitions ===

      def cancel(case_id, payload = {})
        connection.post("#{BASE_PATH}/#{case_id}/cancel", payload)
      end

      def send_to_support(case_id, payload = {})
        connection.post("#{BASE_PATH}/#{case_id}/support", payload)
      end

      def set_assigned(case_id, payload = {})
        connection.post("#{BASE_PATH}/#{case_id}/assigned", payload)
      end

      def send_to_processing(case_id, payload = {})
        connection.post("#{BASE_PATH}/#{case_id}/processing", payload)
      end

      def update_hold_status(case_id, hold:)
        connection.patch("#{BASE_PATH}/#{case_id}/status", hold_status: hold)
      end

      def statuses(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/statuses")
      end

      def events(case_id, params = { page: 1, per_page: 50 })
        connection.get("#{BASE_PATH}/#{case_id}/events", params)
      end

      # === Files attached to a case ===

      def files(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/files")
      end

      def update_files(case_id, file_ids)
        connection.patch("#{BASE_PATH}/#{case_id}/files", files: file_ids)
      end

      def attach_file(case_id, file_id)
        connection.post("#{BASE_PATH}/#{case_id}/files/#{file_id}")
      end

      def detach_file(case_id, file_id)
        connection.delete("#{BASE_PATH}/#{case_id}/files/#{file_id}")
      end

      # === Diseases attached to a case ===

      def diseases(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/diseases")
      end

      def attach_diseases(case_id, diseases)
        connection.post("#{BASE_PATH}/#{case_id}/diseases", diseases: diseases)
      end

      def detach_disease(case_id, disease_id)
        connection.delete("#{BASE_PATH}/#{case_id}/diseases/#{disease_id}")
      end

      def set_primary_disease(case_id, disease_id)
        connection.post("#{BASE_PATH}/#{case_id}/diseases/#{disease_id}/primary")
      end

      # === Clinical notes ===

      def notes(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/notes")
      end

      def create_note(case_id, payload)
        connection.post("#{BASE_PATH}/#{case_id}/notes", payload)
      end

      # === Questions ===

      def questions(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/questions")
      end

      def post_question(case_id, payload)
        connection.post("#{BASE_PATH}/#{case_id}/questions", payload)
      end

      # === Tags ===

      def attach_tag(case_id, tag_id)
        connection.post("#{BASE_PATH}/#{case_id}/tags/#{tag_id}")
      end

      def detach_tag(case_id, tag_id)
        connection.delete("#{BASE_PATH}/#{case_id}/tags/#{tag_id}")
      end

      def update_tag_note(case_id, tag_id, payload)
        connection.patch("#{BASE_PATH}/#{case_id}/tags/#{tag_id}", payload)
      end

      def historical_tags(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/tags/historical")
      end

      # === Prescriptions ===

      def prescriptions(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/prescriptions")
      end

      # === PDFs ===

      def services_pdf(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/pdf")
      end

      def offerings_pdf(case_id)
        connection.get("#{BASE_PATH}/#{case_id}/offerings/pdf")
      end
    end
  end
end
