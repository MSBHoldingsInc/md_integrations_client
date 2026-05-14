module MdIntegrations
  module Resources
    # Partner-wide tag management (attach to cases or patients separately).
    class Tags < Base
      BASE_PATH = '/partner/tags'.freeze

      def list(params = { page: 1, per_page: 15, type: 'global' })
        connection.get(BASE_PATH, params)
      end

      def find(tag_id)
        connection.get("#{BASE_PATH}/#{tag_id}")
      end

      def create(payload)
        connection.post(BASE_PATH, payload)
      end

      def update(tag_id, payload)
        connection.patch("#{BASE_PATH}/#{tag_id}", payload)
      end

      def delete(tag_id)
        connection.delete("#{BASE_PATH}/#{tag_id}")
      end
    end
  end
end
