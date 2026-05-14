module MdIntegrations
  module Resources
    # Vouchers / promotional codes that can be redeemed by patients.
    class Vouchers < Base
      BASE_PATH = '/partner/vouchers'.freeze

      def list(params = { expired: 0 })
        connection.get(BASE_PATH, params)
      end

      def find(voucher_id)
        connection.get("#{BASE_PATH}/#{voucher_id}")
      end

      def create(payload)
        connection.post(BASE_PATH, payload)
      end

      def expire(voucher_id)
        connection.post("#{BASE_PATH}/#{voucher_id}/expire")
      end

      def delete(voucher_id)
        connection.delete("#{BASE_PATH}/#{voucher_id}")
      end
    end
  end
end
