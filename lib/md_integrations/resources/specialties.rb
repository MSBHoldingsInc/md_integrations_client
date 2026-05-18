module MdIntegrations
  module Resources
    class Specialties < Base
      def list
        connection.get('/partner/specialties')
      end
    end
  end
end
