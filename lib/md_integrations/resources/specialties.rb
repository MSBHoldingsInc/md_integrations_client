module MdIntegrations
  module Resources
    class Specialties < Base
      def list
        connection.get('/v1/partner/specialties')
      end
    end
  end
end
