require 'faraday/multipart'

module MdIntegrations
  module Resources
    class Files < Base
      BASE_PATH = '/partner/files'.freeze

      # MDI accepted file types (Partners > Files > Create file):
      TYPE_DOCUMENT         = 'document'.freeze
      TYPE_REVIEW           = 'review'.freeze
      TYPE_OTHER            = 'other'.freeze
      TYPE_INSURANCE_POLICY = 'insurance-policy'.freeze
      TYPE_CONTRACT         = 'contract'.freeze
      TYPE_DRIVER_LICENSE   = 'driver-license'.freeze
      TYPE_LAB_RESULT       = 'lab-result'.freeze
      TYPE_PHOTO            = 'photo'.freeze
      TYPE_AV_VIDEO         = 'av-video'.freeze
      TYPE_FULL_BODY_PHOTO  = 'full-body-photo'.freeze
      TYPE_BACK_PHOTO       = 'back-photo'.freeze
      TYPE_FACE_PHOTO       = 'face-photo'.freeze
      TYPE_AVATAR_PHOTO     = 'avatar-photo'.freeze
      TYPE_IPLEDGE_DOCUMENT = 'ipledge-document'.freeze
      TYPE_AUTH_FORM        = 'auth-form'.freeze

      # Upload a single file via multipart/form-data.
      #
      # @param io [IO]            the file IO (e.g. File.open('x.jpg', 'rb'))
      # @param filename [String]  the original filename
      # @param content_type [String] MIME type
      # @param type [String]      one of the TYPE_* constants
      # @param name [String]      human-readable label for the file (required by MDI)
      def upload(io:, filename:, content_type:, type:, name: nil)
        parts = {
          name: name || filename,
          type: type,
          file: Faraday::Multipart::FilePart.new(io, content_type, filename)
        }

        connection.post_multipart(BASE_PATH, parts)
      end

      def find(file_id)
        connection.get("#{BASE_PATH}/#{file_id}")
      end

      def delete(file_id)
        connection.delete("#{BASE_PATH}/#{file_id}")
      end
    end
  end
end
