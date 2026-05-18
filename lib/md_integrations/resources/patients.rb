module MdIntegrations
  module Resources
    class Patients < Base
      BASE_PATH    = '/partner/patients'.freeze
      V1_BASE_PATH = '/v1/partner/patients'.freeze

      # === Core CRUD ===

      def create(payload)
        connection.post(V1_BASE_PATH, payload)
      end

      def update(patient_id, payload)
        connection.patch("#{V1_BASE_PATH}/#{patient_id}", payload)
      end

      def find(patient_id)
        connection.get("#{V1_BASE_PATH}/#{patient_id}")
      end

      def search(filters = {})
        connection.post("#{V1_BASE_PATH}/search", filters)
      end

      def cases(patient_id, params = {})
        connection.get("#{V1_BASE_PATH}/#{patient_id}/cases", params)
      end

      def events(patient_id, params = { page: 1, per_page: 50 })
        connection.get("#{V1_BASE_PATH}/#{patient_id}/events", params)
      end

      # === Workflow URLs (return a hosted URL the patient can visit) ===

      def drivers_license_url(patient_id, fullscreen: true)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/drivers-license", fullscreen: fullscreen)
      end

      def intro_video_url(patient_id, fullscreen: true)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/intro-video", fullscreen: fullscreen)
      end

      def messaging_app_url(patient_id, case_id: nil, full: true, fullscreen: true)
        params = { full: full, fullscreen: fullscreen }
        params[:case_id] = case_id if case_id
        connection.get("#{V1_BASE_PATH}/#{patient_id}/auth", params)
      end

      def file_request_url(patient_id, fullscreen: true)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/file-url", fullscreen: fullscreen)
      end

      # === Preferred pharmacies ===

      def preferred_pharmacies(patient_id, params = { sort: 'updated_at', order: 'desc' })
        connection.get("#{V1_BASE_PATH}/#{patient_id}/pharmacies", params)
      end

      def add_preferred_pharmacy(patient_id, pharmacy_id)
        connection.post("#{V1_BASE_PATH}/#{patient_id}/pharmacies/#{pharmacy_id}")
      end

      def remove_preferred_pharmacy(patient_id, pharmacy_id)
        connection.delete("#{V1_BASE_PATH}/#{patient_id}/pharmacies/#{pharmacy_id}")
      end

      # === 2FA ===

      def send_otp(payload)
        connection.post("#{BASE_PATH}/auth/2fa", payload)
      end

      def validate_otp(payload)
        connection.post("#{BASE_PATH}/auth/2fa/validate", payload)
      end

      # === Exams ===

      def exams(patient_id)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/exams")
      end

      def exam(patient_id, exam_id)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/exams/#{exam_id}")
      end

      # === Vouchers ===

      def vouchers(patient_id)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/vouchers")
      end

      # === DoseSpot ===

      def dosespot_coverage(patient_id, params = {})
        connection.get("#{V1_BASE_PATH}/#{patient_id}/dosespot/formulary", params)
      end

      def dosespot_medications_history(patient_id)
        connection.get("#{V1_BASE_PATH}/#{patient_id}/dosespot/medications/history")
      end

      # === Tags ===

      def attach_tag(patient_id, tag_id)
        connection.post("#{V1_BASE_PATH}/#{patient_id}/tags/#{tag_id}")
      end

      def detach_tag(patient_id, tag_id)
        connection.delete("#{V1_BASE_PATH}/#{patient_id}/tags/#{tag_id}")
      end

      def update_tag_note(patient_id, tag_id, payload)
        connection.patch("#{V1_BASE_PATH}/#{patient_id}/tags/#{tag_id}", payload)
      end

      # === Subscriptions ===

      def subscriptions(patient_id, params = { page: 1, per_page: 15 })
        connection.get("/partner/patients/#{patient_id}/subscriptions", params)
      end

      # === Compliance / GDPR ===

      def request_data(patient_id: nil, patient_email: nil)
        connection.post("#{BASE_PATH}/data", { patient_id: patient_id, patient_email: patient_email }.compact)
      end

      def request_data_deletion(patient_id)
        connection.delete("#{V1_BASE_PATH}/#{patient_id}")
      end
    end
  end
end
