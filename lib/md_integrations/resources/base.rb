module MdIntegrations
  module Resources
    class Base
      def initialize(connection)
        @connection = connection
      end

      protected

      attr_reader :connection
    end
  end
end
