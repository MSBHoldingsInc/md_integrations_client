module MdIntegrations
  module Resources
    class SupportStaffs < Base
      def find(support_staff_id)
        connection.get("/partner/support-staffs/#{support_staff_id}")
      end
    end

    class InternalSupportStaffs < Base
      def find(internal_support_staff_id)
        connection.get("/partner/internal-support-staffs/#{internal_support_staff_id}")
      end
    end

    class MedicalAssistants < Base
      def find(medical_assistant_id)
        connection.get("/partner/medical-assistants/#{medical_assistant_id}")
      end
    end
  end
end
